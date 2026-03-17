import SwiftUI
import UIKit

struct ImageCropperView: UIViewControllerRepresentable {
    @Binding var image: UIImage
    var onComplete: (UIImage) -> Void
    var onCancel: (() -> Void)?

    func makeUIViewController(context: Context) -> CropViewController {
        let vc = CropViewController()
        vc.image = image
        vc.onComplete = { cropped in onComplete(cropped) }
        vc.onCancel = onCancel
        return vc
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject {}

    class CropViewController: UIViewController, UIScrollViewDelegate {
        var imageView = UIImageView()
        var scrollView = UIScrollView()
        var image: UIImage!
        var onComplete: ((UIImage) -> Void)?
        var onCancel: (() -> Void)?

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            setupScrollView()
            setupToolbar()
        }

        func setupScrollView() {
            scrollView = UIScrollView(frame: view.bounds)
            scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            scrollView.backgroundColor = .black
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 6.0
            view.addSubview(scrollView)

            imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = scrollView.bounds
            imageView.isUserInteractionEnabled = true
            scrollView.addSubview(imageView)

            updateZoomToFit()
        }

        func updateZoomToFit() {
            guard let img = image else { return }
            let scrollSize = scrollView.bounds.size
            let imageSize = img.size
            let widthScale = scrollSize.width / imageSize.width
            let heightScale = scrollSize.height / imageSize.height
            let scale = max(widthScale, heightScale)
            scrollView.minimumZoomScale = scale
            scrollView.zoomScale = scale
            centerImage()
        }

        func centerImage() {
            let scrollSize = scrollView.bounds.size
            let imageViewSize = imageView.frame.size
            let horizontal = imageViewSize.width < scrollSize.width ? (scrollSize.width - imageViewSize.width) / 2 : 0
            let vertical = imageViewSize.height < scrollSize.height ? (scrollSize.height - imageViewSize.height) / 2 : 0
            scrollView.contentInset = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        }

        func setupToolbar() {
            let cropBtn = UIBarButtonItem(title: "Crop", style: .done, target: self, action: #selector(didTapCrop))
            let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancel))
            navigationItem.rightBarButtonItem = cropBtn
            navigationItem.leftBarButtonItem = cancelBtn
            let nav = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
            nav.autoresizingMask = [.flexibleWidth]
            let navItem = UINavigationItem()
            navItem.rightBarButtonItem = cropBtn
            navItem.leftBarButtonItem = cancelBtn
            nav.items = [navItem]
            view.addSubview(nav)

            var f = view.bounds
            f.origin.y += 44
            f.size.height -= 44
            scrollView.frame = f
            imageView.frame = scrollView.bounds
            updateZoomToFit()
        }

        @objc func didTapCancel() { onCancel?() }

        @objc func didTapCrop() {
            let scale = image.size.width / imageView.frame.size.width
            var visibleRect = CGRect()
            visibleRect.origin.x = (scrollView.contentOffset.x + scrollView.contentInset.left) * scale
            visibleRect.origin.y = (scrollView.contentOffset.y + scrollView.contentInset.top) * scale
            visibleRect.size.width = scrollView.bounds.size.width * scale
            visibleRect.size.height = scrollView.bounds.size.height * scale
            guard let cgImage = image.cgImage else { return }
            if let croppedCg = cgImage.cropping(to: visibleRect) {
                let cropped = UIImage(cgImage: croppedCg, scale: image.scale, orientation: image.imageOrientation)
                onComplete?(cropped)
            } else { onComplete?(image) }
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            imageView.frame = scrollView.bounds
            updateZoomToFit()
        }
    }
}
