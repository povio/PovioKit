#  DynamicCollectionCell

A `UICollectionViewCell` subclass providing functionality to dynamically size cells, either vertically or horizontally.

## Usage

To make dynamic size work, there are two thing you need to do.

1. Create a cell and subclass it from `DynamicCollectionCell`.

```swift
/// Cell definition
class VerticalCell: DynamicCollectionCell {
  let titleLabel = UILabel()
  let descriptionLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    direction = .vertical // or `.horizontal`
  }
}
```

2. Set `estimatedItemSize` on collectionView's layout:

```swift
class ViewController: UIViewController {
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews() 
    
    /// We need to tell collection view about the estimated cell size
    (collectionView.collectionViewLayout as? UICollectionViewFlowLayout).map {
      $0.estimatedItemSize = CGSize(width: collectionView.maxContentSize.width), height: 1) // for vertical layout
      // $0.estimatedItemSize = CGSize(width: 1, height: collectionView.maxContentSize.height)) // for horizontal layout
    }
  }
}
```

## Source code
You can find source code [here](/Sources/UI/UIKit/Views/DynamicCollectionCell/DynamicCollectionCell.swift).
