import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
	lazy var displayList = DisplayList()
	lazy var statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
	lazy var menuToDisplayMap = [NSMenu: Display]()

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		statusItem.title = "…"

		buildStatusItemMenu()
	}

	func buildStatusItemMenu() {
		statusItem.menu = NSMenu()
		statusItem.menu?.delegate = self
		statusItem.menu?.autoenablesItems = true

		displayList.displayList.forEach {
			let displayMenu = NSMenu(title: "\($0.currentResolution.width)x\($0.currentResolution.height)")
			displayMenu.delegate = self
			displayMenu.autoenablesItems = true

			menuToDisplayMap[displayMenu] = $0

			$0.supportedResolutions.forEach {
				let title = "\($0.1 + 1) — x\($0.0.width)x\($0.0.height)"
				let displayResolutionMenuItem = NSMenuItem(title: title, action: "selectResolution:", keyEquivalent: "")
				displayResolutionMenuItem.representedObject = $0.1
				displayMenu.addItem(displayResolutionMenuItem)
			}

			let displayMenuItem = statusItem.menu?.addItemWithTitle(displayMenu.title, action: nil, keyEquivalent: "")
			displayMenuItem?.submenu = displayMenu

			statusItem.menu?.addItem(NSMenuItem.separatorItem())
		}

		statusItem.menu?.addItemWithTitle("Quit", action: "terminate:", keyEquivalent: "q'")
	}

	func selectResolution(sender: NSMenuItem) {
		let menu = sender.menu as NSMenu?
		if let display = menuToDisplayMap[menu!], displayResolutionIndex = sender.representedObject as? Int {
			display.setMode(displayResolutionIndex)
		}
	}
}
