import Foundation
import QuartzCore

class DisplayList {
	let displayList: [Display]

	init() {
		var activeDisplayCount: UInt32 = 0
		CGGetActiveDisplayList(0, nil, &activeDisplayCount)

		let activeDisplayList = UnsafeMutablePointer<CGDirectDisplayID>(malloc(sizeof(CGDirectDisplayID) * Int(activeDisplayCount)))
		CGGetActiveDisplayList(activeDisplayCount, activeDisplayList, &activeDisplayCount)

		var displayList = [Display]()
		for i in 0...(activeDisplayCount - 1) {
			let index = Int(i)
			let displayAtIndex = activeDisplayList[index]
			let displayModes = CGDisplayCopyAllDisplayModes(displayAtIndex, nil)
			var displayModesCopy = [CGDisplayModeRef]()
			for j in 0...(CFArrayGetCount(displayModes) - 1) {
				let displayMode = unsafeBitCast(CFArrayGetValueAtIndex(displayModes, CFIndex(j)), CGDisplayModeRef.self)
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
	let activeMode: CGDisplayModeRef
	let supportedModes: [CGDisplayModeRef]

	var currentResolution: CGSize {
		get {
			return CGSizeMake(CGFloat(CGDisplayModeGetWidth(activeMode)), CGFloat(CGDisplayModeGetHeight(activeMode)))
		}
	}

	var supportedResolutions: [(CGSize, Int)] {
		get {
			var supportedResolutions = [(CGSize, Int)]()
			for (i, mode) in supportedModes.enumerate() {
				supportedResolutions.append((CGSizeMake(CGFloat(CGDisplayModeGetWidth(mode)), CGFloat(CGDisplayModeGetHeight(mode))), i))
			}
			return supportedResolutions
		}
	}

	func setMode(modeIndex: Int) {
		let newMode = supportedModes[modeIndex]
		let displayConfig = UnsafeMutablePointer<CGDisplayConfigRef>.alloc(0)
		CGBeginDisplayConfiguration(displayConfig)
		CGConfigureDisplayWithDisplayMode(displayConfig.memory, displayID, newMode, nil)
		CGCompleteDisplayConfiguration(displayConfig.memory, CGConfigureOption.Permanently)
	}
}
