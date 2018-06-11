from germanium.static import close_browser

def after_feature(context, feature):
    close_browser()
