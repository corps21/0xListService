let timeline = gsap.timeline()

timeline.from(".landing-page .link_wrapper, .landing-page .image-and-button",{
  y:-200,
  duration:0.80,
  opacity:0,
  stagger:0.35
})

timeline.from(" .landing-page .headings h1",{
  y:-100,
  duration:0.75,
  opacity:0,
  stagger:0.25
})

timeline.from(".intro",{
  y:-50,
  duration:0.75,
  opacity:0,
})

timeline.from(".section-bottom",{
  y:-50,
  duration:0.25,
  opacity:0,
})

timeline.from("footer",{
    y:-50,
    opacity:0,
    duration:0.50
})

timeline.to("footer",{
  opacity:50,
  y:30,
  duration:1,
  repeat:-1,
  yoyo:true,
  ease:"bounce.Out"
})
