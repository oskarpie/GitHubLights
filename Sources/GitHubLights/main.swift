import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var timer: Timer?
    
    // Store service statuses
    var serviceStatuses: [String: String] = [:]
    
    // Define fixed positions for GitHub services
    // Maps service name to grid position (0-9)
    let servicePositions: [String: Int] = [
        "Git Operations": 0,
        "API Requests": 1,
        "Webhooks": 2,
        "Issues": 3,
        "Pull Requests": 4,
        "Actions": 5,
        "Packages": 6,
        "Pages": 7,
        "Codespaces": 8,
        "Copilot": 9
        // Add more services if needed
    ]
    
    // Reverse mapping to find service by position
    lazy var positionToService: [Int: String] = {
        var mapping: [Int: String] = [:]
        for (service, position) in servicePositions {
            mapping[position] = service
        }
        return mapping
    }()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set up menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(refreshStatus), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Open GitHub Status", action: #selector(openInBrowser), keyEquivalent: "o"))
        menu.addItem(NSMenuItem.separator())
        
        // Add service status submenu items that will be updated
        for position in 0..<10 {
            let serviceName = positionToService[position] ?? "Unknown Service"
            let item = NSMenuItem(title: "\(serviceName): Loading...", action: nil, keyEquivalent: "")
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        
        // Set up timer to refresh status every 5 minutes
        timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(refreshStatus), userInfo: nil, repeats: true)
        
        // Initial fetch
        refreshStatus()
    }
    
    @objc func refreshStatus() {
        fetchGitHubStatus { [weak self] in
            self?.updateStatusBarIcon()
        }
    }
    
    func fetchGitHubStatus(completion: @escaping () -> Void) {
        guard let url = URL(string: "https://www.githubstatus.com/api/v2/summary.json") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data, error == nil,
                  let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let components = jsonObject["components"] as? [[String: Any]] else {
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            
            var statuses: [String: String] = [:]
            
            // Process all services and map them to our known services
            for component in components {
                if let name = component["name"] as? String,
                   let status = component["status"] as? String,
                   name != "GitHub Status" {
                    // Only store services we've defined in our position map
                    if self.servicePositions[name] != nil {
                        statuses[name] = status
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.serviceStatuses = statuses
                completion()
            }
        }
        
        task.resume()
    }
    
    func updateStatusBarIcon() {
        // Create a 5x2 grid of colored dots
        let size = NSSize(width: 52, height: 18)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Background - slightly darker to make traffic lights stand out
        NSColor.clear.set()
        NSRect(x: 0, y: 0, width: size.width, height: size.height).fill()
        
        // Optional: Draw a subtle background container for the dots
        NSColor.black.withAlphaComponent(0.1).set()
        let bgRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: 4, yRadius: 4)
        bgPath.fill()
        
        // Draw dots in a 5x2 grid
        let dotSize: CGFloat = 6
        let spacing: CGFloat = 4
        
        // Iterate through all possible positions (0-9)
        for position in 0..<10 {
            let row = position / 5
            let col = position % 5
            
            // Find the service for this position
            if let serviceName = positionToService[position] {
                // Get the status or default to unknown
                let status = serviceStatuses[serviceName] ?? "unknown"
                let dotColor = colorForStatus(status)
                
                let x = CGFloat(col) * (dotSize + spacing)
                let y = CGFloat(row) * (dotSize + spacing)
                
                // Draw filled circle with traffic light colors
                dotColor.set()
                let dotRect = NSRect(x: x, y: y, width: dotSize, height: dotSize)
                let path = NSBezierPath(ovalIn: dotRect)
                path.fill()
                
                // Add slight highlight for 3D effect like traffic lights
                NSColor.white.withAlphaComponent(0.3).set()
                let highlightPath = NSBezierPath()
                highlightPath.move(to: NSPoint(x: x + dotSize/2, y: y + dotSize - 1))
                highlightPath.line(to: NSPoint(x: x + dotSize - 1, y: y + dotSize/2))
                highlightPath.line(to: NSPoint(x: x + dotSize/2, y: y + 1))
                highlightPath.line(to: NSPoint(x: x + 1, y: y + dotSize/2))
                highlightPath.close()
                highlightPath.fill()
            }
        }
        
        image.unlockFocus()
        
        // Set the image to the status item
        statusItem.button?.image = image
        
        // Update menu items with service statuses
        if let menuItems = statusItem.menu?.items {
            // Start at index 2 to skip the first few menu items (Refresh, Open GitHub Status, separator)
            var menuIndex = 3
            
            // Update menu items based on fixed positions
            for position in 0..<10 {
                if let serviceName = positionToService[position] {
                    let status = serviceStatuses[serviceName] ?? "Unknown"
                    let statusEmoji = status.lowercased() == "operational" ? "🟢" : 
                                      status.lowercased().contains("degraded") ? "🟠" : 
                                      status.lowercased().contains("outage") ? "🔴" : "⚪️"
                    
                    if menuIndex < menuItems.count - 2 {
                        menuItems[menuIndex].title = "\(statusEmoji) \(serviceName): \(status.replacingOccurrences(of: "_", with: " ").capitalized)"
                    }
                }
                menuIndex += 1
            }
        }
    }
    
    func colorForStatus(_ status: String) -> NSColor {
        switch status.lowercased() {
        case "operational":
            return NSColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0) // Bright traffic light green
        case "degraded_performance", "partial_outage":
            return NSColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0) // Traffic light orange/amber
        case "major_outage":
            return NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) // Bright traffic light red
        default:
            return NSColor.lightGray
        }
    }
    
    @objc func openInBrowser() {
        if let url = URL(string: "https://www.githubstatus.com") {
            NSWorkspace.shared.open(url)
        }
    }
}

// Main entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Set activation policy to accessory to make it a background app
app.setActivationPolicy(.accessory)

app.run()
