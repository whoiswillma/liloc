//
//  LLTableViewHeaderManager.swift
//  Liloc
//
//  Created by William Ma on 6/21/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import UIKit


protocol LLTableViewShadowHeader {

    var shadowManager: LLLayerShadowManager? { get }

}

protocol LLTableViewHeaderManagerDelegate: AnyObject {

    func tableViewHeaderManagerDidLayoutHeaders(_ manager: LLTableViewHeaderManager)

    func tableViewHeaderManager(
        _ manager: LLTableViewHeaderManager,
        headerForSection section: Int
    ) -> UIView?

    func tableViewHeaderManager(
        _ manager: LLTableViewHeaderManager,
        didRemoveHeader header: UIView,
        forSection section: Int
    )

    func tableViewHeaderManagerDidFinishUpdatingHeaders(_ manager: LLTableViewHeaderManager)

}

extension LLTableViewHeaderManagerDelegate {

    func tableViewHeaderManagerDidLayoutHeaders(_ manager: LLTableViewHeaderManager) { }

    func tableViewHeaderManager(
        _ manager: LLTableViewHeaderManager,
        didRemoveHeader header: UIView,
        forSection section: Int
    ) { }

    func tableViewHeaderManagerDidFinishUpdatingHeaders(_ manager: LLTableViewHeaderManager) { }

}

/**
 The `LLTableViewHeaderManager` adjusts the frames of headers that it overlays
 on top of a `UITableView`'s headers.

 ## Layout

 The `LLTableViewHeaderManager` computes the positions of headers in its
 `layoutHeaders` method. Call this method whenever the table view scrolls or
 its geometry changes.

 Moreover, calling `layoutHeaders` updates the `headerGeometries` property,
 which may be useful in the delegate method
 `tableViewHeaderManagerDidLayoutHeaders(_ manager: LLTableViewHeaderManager)`
 for determining the semantic positioning of headers.

 ## UITableViewDelegate

 In order to function properly, the managed table view must be aware of the
 heights of headers. The header manager provides two methods which correspond
 with two `UITableViewDelegate` methods to manage the layout and headers of
 the managed table view.

 - `heightForHeader(inSection:)` is equal to
 `tableView(_:heightForHeaderInSection:)`
 - `viewForHeader(inSection:)` is equal to
 `tableView(_:viewForHeaderInSection:)`
 */
class LLTableViewHeaderManager {

    struct HeaderGeometry {

        enum Position {

            case pinnedTop
            case floating
            case pinnedBottom

        }

        let position: Position

        let frameInTableView: CGRect
        let frameInSuperview: CGRect

    }

    /**
     The headers managed by this header manager.
     */
    private(set) var headers: [UIView] = []

    /**
     The most recently computed geometries for `headers`.

     After calling `layoutHeaders`, this array always contains the same number
     of elements as the `headers` array.
     */
    private(set) var headerGeometries: [HeaderGeometry] = []

    var pinsHeadersToTop = true {
        didSet {
            layoutHeaders()
        }
    }

    var pinsHeadersToBottom = true {
        didSet {
            layoutHeaders()
        }
    }

    var addsShadowsToInnermostHeaders = true {
        didSet {
            layoutHeaders()
        }
    }

    weak var tableView: UITableView!

    weak var delegate: LLTableViewHeaderManagerDelegate!

    init(tableView: UITableView, delegate: LLTableViewHeaderManagerDelegate) {
        self.tableView = tableView
        self.delegate = delegate
    }

    /**
     Query the delegate to add or remove header views from the manager.

     ## Postcondition

     The `headers` array will have the same number of elements as there are
     sections in the table view, that is
     `headers.count == tableView.numberOfSections`
     */
    private func addOrRemoveHeadersAsNeeded() {
        let didUpdateHeaders = headers.count != tableView.numberOfSections

        while headers.count < tableView.numberOfSections {
            let section = headers.count
            if let header = delegate.tableViewHeaderManager(self, headerForSection: section) {
                tableView.addSubview(header)
                headers.append(header)
            } else {
                headers.append(UIView())
            }
        }

        while headers.count > tableView.numberOfSections {
            let section = headers.count - 1
            let header = headers.removeLast()
            header.removeFromSuperview()
            delegate.tableViewHeaderManager(self, didRemoveHeader: header, forSection: section)
        }

        if didUpdateHeaders {
            delegate.tableViewHeaderManagerDidFinishUpdatingHeaders(self)
        }
    }

    /**
     Compute the semantic position and the frames of each header in the table
     view and the superview.

     ## Superview

     This method does one of two things depending on whether `tableView` has
     a superview or not.
     - If `tableView` has a superview, this method computes the geometries of
     each header based on the `pinsHeadersToTop` and `pinsHeadersToBottom`
     properties, and sets the `frameInTableView` and `frameInSuperview` to the
     correct values.
     - If `tableView` has no superview, this method marks the semantic position
     of each header as floating and supplies the `tableView`'s computed position
     for the header, ignoring the `pinsHeadersToTop` and `pinsHeadersToBottom`
     properties. Moreover, it sets the `frameInSuperview` property to
     `CGRect.null`.

     ## Precondition

     The `headers` array must contain the same number of elements as sections
     in the table view, that is `headers.count == tableView.numberOfSections`

     ## Postcondition

     After this method returns, the `headerGeometries` property will contain
     the same number of elements as headers.
     */
    private func computeHeaderGeometries() {
        guard let superview = tableView.superview else {
            headerGeometries = (0..<headers.count).map { section in
                HeaderGeometry(position: .floating,
                               frameInTableView: tableView.rectForHeader(inSection: section),
                               frameInSuperview: .null)
            }
            return
        }

        var topHeadersMaxY = tableView.frame.minY + tableView.safeAreaInsets.top
        var bottomHeadersMinY = tableView.frame.maxY - headers.map { $0.frame.height }.reduce(0, +)
        headerGeometries = headers.enumerated().map { i, header -> HeaderGeometry in
            let sectionHeaderInView = superview.convert(tableView.rectForHeader(inSection: i), from: tableView)

            let position: HeaderGeometry.Position
            let y: CGFloat

            if pinsHeadersToTop, sectionHeaderInView.minY < topHeadersMaxY {
                position = .pinnedTop
                y = topHeadersMaxY

                topHeadersMaxY += sectionHeaderInView.height
            } else if pinsHeadersToBottom, sectionHeaderInView.minY > bottomHeadersMinY {
                position = .pinnedBottom
                y = bottomHeadersMinY
            } else {
                position = .floating
                y = sectionHeaderInView.minY
            }

            bottomHeadersMinY += header.frame.height

            let frameInSuperview = CGRect(origin: CGPoint(x: 0, y: y), size: sectionHeaderInView.size)
            return HeaderGeometry(position: position,
                                  frameInTableView: tableView.convert(frameInSuperview, from: superview),
                                  frameInSuperview: frameInSuperview)
        }
    }

    func layoutHeaders() {
        addOrRemoveHeadersAsNeeded()

        computeHeaderGeometries()

        let headersAndGeometries = Array(zip(headers, headerGeometries))

        for (header, geometry) in zip(headers, headerGeometries) {
            if header.superview !== tableView {
                header.removeFromSuperview()
                tableView.addSubview(header)
            }

            header.frame = geometry.frameInTableView
        }

        for header in headers {
            if let shadowHeader = header as? LLTableViewShadowHeader {
                shadowHeader.shadowManager?.shadowMask = []
            }
        }

        if addsShadowsToInnermostHeaders {
            headersAndGeometries
                .last { $1.position == .pinnedTop }.map{ $0.0 as? LLTableViewShadowHeader }??
                .shadowManager?.shadowMask = [.bottom]

            headersAndGeometries
                .first { $1.position == .pinnedBottom }.map{ $0.0 as? LLTableViewShadowHeader }??
                .shadowManager?.shadowMask = [.top]
        }

        delegate?.tableViewHeaderManagerDidLayoutHeaders(self)
    }

    func heightForHeader(inSection section: Int) -> CGFloat {
        addOrRemoveHeadersAsNeeded()

        return headers[section]
            .systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height))
            .height
    }

    func viewForHeader(inSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)

        // the table view headers may be overlayed on top of the headers,
        // but we still want user interaction for our custom headers
        view.isUserInteractionEnabled = false

        return view
    }

}
