import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
	lazy var displayList = DisplayList()
	lazy var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
	lazy var menuToDisplayMap = [NSMenu: Display]()

	func applicationDidFinishLaunching(_ notification: Notification) {
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
				let displayResolutionMenuItem = NSMenuItem(title: title, action: #selector(selectResolution(_:)), keyEquivalent: "")
				displayResolutionMenuItem.representedObject = $0.1
				displayMenu.addItem(displayResolutionMenuItem)
			}

			let displayMenuItem = statusItem.menu?.addItem(withTitle: displayMenu.title, action: nil, keyEquivalent: "")
			displayMenuItem?.submenu = displayMenu

			statusItem.menu?.addItem(NSMenuItem.separator())
		}

//		statusItem.menu?.addItem(withTitle: "Quit", action: #selector(terminate(_:)), keyEquivalent: "q")
	}

	@objc func selectResolution(_ sender: NSMenuItem) {
		let menu = sender.menu as NSMenu?
		if let display = menuToDisplayMap[menu!], let displayResolutionIndex = sender.representedObject as? Int {
			display.setMode(displayResolutionIndex)
		}
	}
}
