//
//  File.swift
//  
//
//  Created by Tasin Zarkoob on 02/02/2020.
//

import UIKit

public protocol TZCollectionItem {
    var image : UIImage { get set }
}

open class TZDragDropCollectionView: UIView {
    open var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = .clear
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CELL")
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
            collectionView.dragInteractionEnabled = true
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        }
    }
    public typealias DidFinishReorderingItems = ([TZCollectionItem]) -> Void
    /** Number of coloumns per row */
    public var columnsCount : CGFloat = 3 {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    /** Image Array */
    public var items: [TZCollectionItem] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    /** Gets called after reordering items have finished */
    public var didFinishReorderCompletionHandler: DidFinishReorderingItems?
    
    public func reloadData() {
        collectionView.reloadData()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override public func awakeFromNib() {
        self.setupUI()
    }
    
    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        if collectionView == nil {
            collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
            self.addSubview(collectionView)
        }
    }
    
}

extension TZDragDropCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
        cell.backgroundColor = .white
        let image = self.items[indexPath.row].image
        if let imageView = cell.viewWithTag(99) as? UIImageView {
            imageView.image = image
        } else {
            let imageView = UIImageView(image: image)
            imageView.tag = 99
            imageView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(imageView)
            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4).isActive = true
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 4).isActive = true
            imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -4).isActive = true
            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4).isActive = true
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
        }
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = (collectionView.frame.width - 8) / columnsCount
        return CGSize(width: length, height: length)
    }
}

extension TZDragDropCollectionView: UICollectionViewDragDelegate {
    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.items[indexPath.row]
        let itemProvider = NSItemProvider(object: item.image)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension TZDragDropCollectionView: UICollectionViewDropDelegate {
    public func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath : IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        if coordinator.proposal.operation == .move {
            self.reorderItems(coordinator: coordinator, destinationindexPath: destinationIndexPath, collectionView: collectionView)
        }
    }
    
    fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator,
                                  destinationindexPath: IndexPath,
                                  collectionView: UICollectionView)
    {
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath {
            
            collectionView.performBatchUpdates({
                
                let movedItem = self.items[sourceIndexPath.item]
                self.items.remove(at: sourceIndexPath.item)
                self.items.insert(movedItem, at: destinationindexPath.item)
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationindexPath])
                
            }) { (success) in
                self.didFinishReorderCompletionHandler?(self.items)
            }
            coordinator.drop(item.dragItem, toItemAt: destinationindexPath)
        }
        
    }
}
