(function(){

	let dom_hook      = "#watch-headline-title"
	let hack_elem_id  = "yt-hack-maximize-video-button"
	let styles        = new WeakMap()
	let modified      = []

	var click = maximize_video
	var button

	function set_style(o, s){
		if (! styles.has(o)) {
			let s = o.getAttribute("style")
			console.log("backing up style", s, "from", o)
			styles.set(o, s)
		} // backup style only once
		o.setAttribute("style", s) // set new value
		if (modified.indexOf(o) < 0) { modified.push(o); } // tag object as modified
	}

	function reset_style(o) {
		let s = styles.get(o)
		console.log("resetting style", s, "of", o)
		o.setAttribute("style", s)
	}

	function reset_video(){
		for(o of modified){ reset_style(o) }
		click = maximize_video
		button.innerText = "|<- maximize ->|"
	}

	function maximize_video(){
		let selectors = [
			"#placeholder-player > .player-api",
			".video-stream",
			"video",
			".html5-video-container",
			"#movie_player",
			"#player-api"
		]
		var elem, s, prev = {}
		for(sel of selectors) {
			elem = $(sel) || prev.parentNode
			if(elem){
				console.log("fixing:", elem, elem.style)
				set_style(elem, `
					width:       1200px;
					height:      800px;
					max-width:   "";
					max-height:  "";
					margin-left: 50%;
					left:       -50%;
				`
				)
				prev = elem
			} else {
				console.error("cannot find element", sel)
			}
		}
		// get last elem and add some margin
		prev.style.marginLeft = "0px"
		prev.style.left       = "20px"

		let pls  = $("#watch-appbar-playlist")
		let ppls = $("#placeholder-playlist")
		set_style( pls,  "display: none" )
		set_style( ppls, "height:  0px"  )
		click = reset_video
		button.innerText = "->| minimize |<-"
	}

	var sleep = 1000
	function add_title_button(){
		let wht = $(dom_hook)
      if(!wht){
			console.warn("cannot find dom_hook: ", dom_hook)
			console.log("trying to add_title_button again in", sleep, "ms")
			window.setTimeout(add_title_button, sleep)
			sleep *= 2
			return
		}
		console.log("setting up youtube maximize_video hack")
		let old_but = $("#" + hack_elem_id)
		if (old_but) { old_but.remove() }

		let but = document.createElement("button")
		but.classList = ["yt-uix-button", "yt-uix-button-size-default"]
		but.id        = hack_elem_id 
		but.type      = "button"
		but.addEventListener("click", (e) => click() )
		button = but

		s = but.style
		s.borderStyle     = "solid"
		s.borderWidth     = "1px"
		s.backgroundColor = "#ccc"
		s.cursor          = "pointer"
		s.borderRadius    = "3px"
		s.height          = "20pt"

		wht.appendChild(but)
		reset_video()
	}

	add_title_button()

})()

