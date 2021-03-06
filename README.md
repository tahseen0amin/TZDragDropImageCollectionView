# TZDragDropImageCollectionView

View containing a collection of UIImages and that supports Drag and Drop feature. 

### Installation
Use Swift Package Manager.

### Usage
 In your xib file or Storyboard, click on the UIView, go to the Identity Inspector and change the Custom Class to **TZDragDropImageCollectionView**.
 In your ViewController, set the items of the collection view
```swift
let images = [UIImage(systemName: "plus")!, UIImage(systemName: "pencil")!, UIImage(systemName: "trash")!, UIImage(systemName: "folder")!]
(self.view as? TZDraggableCollectionView)?.items = images.shuffled()
```
Change the Column Count if required. default is 3.
```swift
(self.view as? TZDraggableCollectionView)?.columnsCount = 2
```

Use Closure to get new reordered array.
```swift
(self.view as? TZDraggableCollectionView)?.didFinishReorderCompletionHandler = { shuffled in
    if images == shuffled {
        print("Correct")
    }
}
```

# Reference
Read this blog. Most of the code is from this blog
[Drag, Drop & Reorder Collection View Cells into One or More UICollectionView by Max Nelson](https://medium.com/hackernoon/how-to-drag-drop-uicollectionview-cells-by-utilizing-dropdelegate-and-dragdelegate-6e3512327202)

# License
Free to use


