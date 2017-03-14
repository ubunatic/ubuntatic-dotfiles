#!/usr/bin/env python

import gobject, gtk, appindicator, os, threading, sched, time

def vmcount(): return sh_vboxcount() + sh_dockercount()

def sh_vboxcount():
    ps = os.popen("pgrep VBoxHeadless").read()
    return len(ps)

def sh_dockercount():
    ps = os.popen("docker ps -aq").read()
    return len(ps)

def sh_date():
    return int(os.popen("date +%s").read())

def menuitem_response(w, buf): print buf

class App():
    def __init__(self):
        #cool icons:
        #
        # [i]   ibus
        # [>_]  bash, terminal
        # ==    server
        # cube  package-x-generic-symbolic
        # cube  virtualbox-vbox 

        icon = "server"
        name = "vm-indicator-client"
        text_add_script = "add script..."
        text_rm_script  = "remove script {}"
        
        ind = self.ind = appindicator.Indicator(
			name,
			icon,
			appindicator.CATEGORY_APPLICATION_STATUS
		)
        ind.set_status (appindicator.STATUS_ACTIVE)
        self.menu = gtk.Menu()

        action = menuitem_response
        
        self.add_menuitem (text_add_script, action)
        self.add_menuitem (text_rm_script.format("docker"), action)
        
        ind.set_menu(self.menu)

    def update(self):
        self.set_label("%d" % vmcount())

    def set_label(self,label):
        self.ind.set_label(label)

    def add_menuitem(self,buf,action):
        menu_items = gtk.MenuItem(buf)
        self.menu.append(menu_items)
        menu_items.connect("activate", action, buf)
        menu_items.show()

def main_loop(sleep,action):
    ts = 0

    while True:
        # ensure UI stays reactive
        while gtk.events_pending():
            gtk.mainiteration()

        # schedule update
        if time.time() > ts + sleep:
            action()
            ts = time.time()

        # prevent full-load loop 
        time.sleep(0.1)



if __name__ == "__main__":
    app = App()
    main_loop(1,app.update)
