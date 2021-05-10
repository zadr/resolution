import Foundation
import QuartzCore

class DisplayList {
	let displayList: [Display]

	init() {
		var activeDisplayCount: UInt32 = 0
		CGGetActiveDisplayList(0, nil, &activeDisplayCount)

		let activeDisplayList = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: Int(activeDisplayCount))
		CGGetActiveDisplayList(activeDisplayCount, activeDisplayList, &activeDisplayCount)

		var displayList = [Display]()
		for i in 0...(activeDisplayCount - 1) {
			let index = Int(i)
			let displayAtIndex = activeDisplayList[index]
			let displayModes = CGDisplayCopyAllDisplayModes(displayAtIndex, nil)
			var displayModesCopy = [CGDisplayMode]()
			for j in 0...(CFArrayGetCount(displayModes) - 1) {
				let displayMode = unsafeBitCast(CFArrayGetValueAtIndex(displayModes, CFIndex(j)), to: CGDisplayMode.self)
				displayModesCopy.append(displayMode)
			}
			let display = Display(displayID: displayAtIndex, activeMode: CGDisplayCopyDisplayMode(displayAtIndex)!, supportedModes: displayModesCopy)
			displayList.append(display)
		}
		self.displayList = displayList

		free(activeDisplayList)
	}
}

struct Display {
	let displayID: CGDirectDisplayID
	let activeMode: CGDisplayMode
	let supportedModes: [CGDisplayMode]

	var currentResolution: CGSize {
		return CGSize(width: CGFloat(activeMode.width), height: CGFloat(activeMode.height))
	}

	var supportedResolutions: [(CGSize, Int)] {
		var supportedResolutions = [(CGSize, Int)]()
		for (i, mode) in supportedModes.enumerated() {
			supportedResolutions.append((CGSize(width: CGFloat(mode.width), height: CGFloat(mode.height)), i))
		}
		return supportedResolutions
	}

	func setMode(_ modeIndex: Int) {
		let newMode = supportedModes[modeIndex]
		let displayConfig = UnsafeMutablePointer<CGDisplayConfigRef?>.allocate(capacity: 0)
		CGBeginDisplayConfiguration(displayConfig)
		CGConfigureDisplayWithDisplayMode(displayConfig.pointee, displayID, newMode, nil)
		CGCompleteDisplayConfiguration(displayConfig.pointee, .permanently)
	}
}
