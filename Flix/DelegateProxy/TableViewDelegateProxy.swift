//
//  TableViewDelegateProxy.swift
//  Flix
//
//  Created by DianQK on 22/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit

class TableViewDelegateProxy: NSObject, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return self.editActionsForRowAt?(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightForRowAt?(tableView, indexPath) ?? tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.heightForHeaderInSection?(tableView, section) ?? tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.viewForHeaderInSection?(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.heightForFooterInSection?(tableView, section) ?? tableView.sectionFooterHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.viewForFooterInSection?(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return self.titleForDeleteConfirmationButtonForRowAt?(tableView, indexPath) ?? "Delete"
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return self.editingStyleForRowAt?(tableView, indexPath) ?? UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return self.targetIndexPathForMoveFromRowAt?(tableView, sourceIndexPath, proposedDestinationIndexPath) ?? proposedDestinationIndexPath
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return self.leadingSwipeActionsConfigurationForRowAt?(tableView, indexPath) as? UISwipeActionsConfiguration
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return self.trailingSwipeActionsConfigurationForRowAt?(tableView, indexPath) as? UISwipeActionsConfiguration
    }

    var heightForRowAt: ((_ tableView: UITableView, _ indexPath: IndexPath) -> CGFloat?)?
    var heightForFooterInSection: ((_ tableView: UITableView, _ section: Int) -> CGFloat?)?
    var heightForHeaderInSection: ((_ tableView: UITableView, _ section: Int) -> CGFloat?)?
    var viewForHeaderInSection: ((_ tableView: UITableView, _ section: Int) -> UIView?)?
    var viewForFooterInSection: ((_ tableView: UITableView, _ section: Int) -> UIView?)?
    var editActionsForRowAt: ((_ tableView: UITableView, _ indexPath: IndexPath) -> [UITableViewRowAction]?)?
    var targetIndexPathForMoveFromRowAt: ((_ tableView: UITableView, _ sourceIndexPath: IndexPath, _ proposedDestinationIndexPath: IndexPath) -> IndexPath)?
    var titleForDeleteConfirmationButtonForRowAt:  ((_ tableView: UITableView, _ indexPath: IndexPath) -> String?)?
    var editingStyleForRowAt: ((_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell.EditingStyle)?

    var leadingSwipeActionsConfigurationForRowAt: ((_ tableView: UITableView, _ indexPath: IndexPath) -> NSObject?)?
    var trailingSwipeActionsConfigurationForRowAt: ((_ tableView: UITableView, _ indexPath: IndexPath) -> NSObject?)?

}

