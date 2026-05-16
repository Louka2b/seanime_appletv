import SwiftUI
import UIKit

struct SeanimeWebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> UIView {
        let path = "/System/Library/Frameworks/WebKit.framework/WebKit"
        _ = dlopen(path, RTLD_NOW)
        
        guard let wkWebViewClass = NSClassFromString("WKWebView") as? NSObject.Type else {
            return UIView()
        }
        
        let webView = wkWebViewClass.init() as! UIView
        
        // Settings for TV environment
        let configSelector = NSSelectorFromString("configuration")
        if webView.responds(to: configSelector), 
           let config = webView.perform(configSelector)?.takeUnretainedValue() {
            (config as AnyObject).setValue(true, forKey: "allowsInlineMediaPlayback")
        }

        // JS Navigation Engine for Siri Remote
        let navigationScript = """
        (function() {
            if (window.tvFocusInitialized) return;
            window.tvFocusInitialized = true;

            var style = document.createElement('style');
            style.innerHTML = `
                :focus {
                    outline: 10px solid #3e8ed0 !important;
                    outline-offset: 5px !important;
                    transform: scale(1.03) !important;
                    transition: transform 0.1s ease-out !important;
                    box-shadow: 0 0 40px rgba(62, 142, 208, 0.5) !important;
                    z-index: 999999 !important;
                }
                ::-webkit-scrollbar { width: 0px !important; }
            `;
            document.head.appendChild(style);

            document.addEventListener('keydown', function(e) {
                const focusable = 'button, [href], input, select, .anime-card, .episode-item, [tabindex]';
                const items = Array.from(document.querySelectorAll(focusable)).filter(i => i.offsetParent !== null);
                let index = items.indexOf(document.activeElement);

                if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
                    index = (index + 1) % items.length;
                    items[index].focus();
                    items[index].scrollIntoView({ behavior: 'smooth', block: 'center' });
                    e.preventDefault();
                } else if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
                    index = (index - 1 + items.length) % items.length;
                    items[index].focus();
                    items[index].scrollIntoView({ behavior: 'smooth', block: 'center' });
                    e.preventDefault();
                }
            });
            
            // Auto-focus on first element
            setTimeout(() => {
                const first = document.querySelector('button, [href], .anime-card');
                if (first) first.focus();
            }, 3000);
        })();
        """

        let request = URLRequest(url: url)
        webView.perform(NSSelectorFromString("loadRequest:"), with: request)
        
        // Inject script after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            webView.perform(NSSelectorFromString("evaluateJavaScript:completionHandler:"), with: navigationScript, with: nil)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
