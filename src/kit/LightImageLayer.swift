import Cocoa

/// this is a lightweight CALayer which displays an image
/// it is an alternative to NSView-based image display, avoiding AppKit overhead (layout recursion, responder chain, drag-and-drop)
class LightImageLayer: CALayer {
    override init() {
        super.init()
        contentsGravity = .resize
        magnificationFilter = .trilinear
        minificationFilter = .trilinear
        minificationFilterBias = 0.0
        shouldRasterize = false
        delegate = NoAnimationDelegate.shared
    }

    required init?(coder: NSCoder) {
        fatalError("Class only supports programmatic initialization")
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    func updateContents(_ caLayerContents: CALayerContents, _ size: NSSize) {
        switch caLayerContents {
        case .cgImage(let image?):
            updateContentsIfNeeded(image)
        case .pixelBuffer(let pixelBuffer?):
            if let surface = CVPixelBufferGetIOSurface(pixelBuffer)?.takeUnretainedValue() {
                updateContentsIfNeeded(surface)
            }
        default: break
        }
        if frame.size != size {
            frame.size = size
        }
    }

    private func updateContentsIfNeeded(_ value: AnyObject) {
        if let current = contents as AnyObject?, current === value { return }
        contents = value
    }

    func releaseImage() {
        contents = nil
    }
}
