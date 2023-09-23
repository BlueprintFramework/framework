<a onclick="hideOnboarding()">
  <div id="onboardingSiteOverlay" class="onboarding-site-overlay"></div>
</a>
<div id="onboardingContainer" class="onboarding-container">
  <div class="onboarding-content-box">
    <div class="onboarding-content">
      <h2 class="onboarding-content-title">this is a title</h2>
      <img src="https://i.imgur.com/hO4PjMD.png" class="onboarding-emoji" id="onboardingEmoji"/>
      <!-- text -->
      <p class="onboarding-content-text">this is text</p>
      
      <!-- bold text -->
      <p class="onboarding-content-text-bold">this is bold text</p>
      
      <!-- boxed text -->
      <div class="onboarding-content-text-box">
        <p class="onboarding-content-text-dim">this is boxed text</p>
      </div>
      
      <!-- button -->
      <button class="onboarding-content-button" role="button">this is a button</button>
      
      <!-- image -->
      <img src="https://i.imgur.com/vWxvUEu.jpg" class="onboarding-content-image"/>
      
    </div>
  </div>
  <div class="onboarding-controls">
    <a onclick="hideOnboarding()">
      <button class="onboarding-controls-button-alt" role="button">Remind me later</button>
    </a>
    <a onclick="closeOnboarding()">
      <button class="onboarding-controls-button" role="button">Confirm</button>
    </a>
  </div>
</div>
<div id="onboardingCloseAlert" class="onboarding-close-alert">
  <!-- Text to show when someone clicked "close". -->
  <p>modal has been closed</p>
</div>
<div id="onboardingHideAlert" class="onboarding-close-alert">
  <!-- Text to show when someone clicked "remind me later". -->
  <p>modal has been hidden until next reload</p>
</div>

<script>
  // Set to false to show the modal every reload
  // even if the user closed the modal.
  hidden=true

  function hideOnboarding() {
    onboardingSiteOverlay = document.getElementById("onboardingSiteOverlay")
    onboardingContainer = document.getElementById("onboardingContainer")
    onboardingHideAlert = document.getElementById("onboardingHideAlert")
    
    onboardingSiteOverlay.style.opacity = 0
    onboardingContainer.style.opacity = 0
    onboardingContainer.style.scale = 0.98
    setTimeout(function() {
      onboardingSiteOverlay.style.display = "none"
      onboardingContainer.style.display = "none"
    }, 600)
    
    onboardingHideAlert.style.display = "inline"
    onboardingHideAlert.style.bottom = "-100px"
    setTimeout(function() {
      onboardingHideAlert.style.bottom = "15px"
    }, 20)
    setTimeout(function() {
      onboardingHideAlert.style.bottom = "-100px"
      setTimeout(function() {
        onboardingHideAlert.style.display = "none"
      }, 2000)
    }, 7500)
    hidden=true
  }

  function closeOnboarding() {
    onboardingSiteOverlay = document.getElementById("onboardingSiteOverlay")
    onboardingContainer = document.getElementById("onboardingContainer")
    onboardingCloseAlert = document.getElementById("onboardingCloseAlert")
    
    onboardingSiteOverlay.style.opacity = 0
    onboardingContainer.style.opacity = 0
    onboardingContainer.style.scale = 0.98
    setTimeout(function() {
      onboardingSiteOverlay.style.display = "none"
      onboardingContainer.style.display = "none"
    }, 600)
    
    
    onboardingCloseAlert.style.display = "inline"
    onboardingCloseAlert.style.bottom = "-100px"
    setTimeout(function() {
      onboardingCloseAlert.style.bottom = "15px"
    }, 20)
    setTimeout(function() {
      onboardingCloseAlert.style.bottom = "-100px"
      setTimeout(function() {
        onboardingCloseAlert.style.display = "none"
      }, 2000)
    }, 7500)
    setCookie("container-open", "no", 999)
    hidden=true
  }

  /* do this when cookie no register */
  if(!getCookie("container-open") || getCookie("container-open") != "no") {
    hidden=false
    onboardingSiteOverlay = document.getElementById("onboardingSiteOverlay")
    onboardingContainer = document.getElementById("onboardingContainer")
    
    onboardingSiteOverlay.style.display = "inline"
    onboardingContainer.style.display = "inline"
    
    onboardingSiteOverlay.style.opacity = 0
    onboardingContainer.style.opacity = 0
    onboardingContainer.style.scale = 0.95
    
    setTimeout(function() {
      onboardingSiteOverlay.style.opacity = 0.2
      onboardingContainer.style.opacity = 1
      onboardingContainer.style.scale = 1
    }, 20)
  }

  /* allow modal to be closed with esc key */
  document.onkeydown = function(evt) {
    evt = evt || window.event;
    var isEscape = false;
    if ("key" in evt) {
      isEscape = (evt.key === "Escape" || evt.key === "Esc");
    } else {
      isEscape = (evt.keyCode === 27);
    }
    if (isEscape) {
      if(!hidden) {
        hideOnboarding()
      }
    }
  }


  /* cookie js code to make my life less miserable */
  function setCookie(cname, cvalue, exdays) {
    const d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    let expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
  }

  function getCookie(cname) {
    let name = cname + "=";
    let ca = document.cookie.split(';');
    for(let i = 0; i < ca.length; i++) {
      let c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return "";
  }
</script>
<style>
  @import url('https://fonts.googleapis.com/css?family=Inter&display=swap');

  body {
    font-family: 'Inter', sans-serif;
    background-color: #32404D;
  }

  .onboarding-close-alert {
    display:none; /* will be changed by javascript */
    transition: 1.5s;
    position: fixed;
    right: 25px;
    bottom: 15px;
    z-index: 100;
    color: white;
    background-color: #2A3439;
    padding-left: 20px;
    padding-right: 20px;
    padding-top: 12px;
    padding-bottom: 12px;
    border-radius: 10px;
  }

  .onboarding-site-overlay {
    background-color: #000;
    opacity: 0.2;
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    transition: opacity 0.5s;
    display:none; /* will be changed by javascript */
    z-index: 98;
  }

  .onboarding-content-image {
    width: 100%;
    border-radius: 12px;
  }

  .onboarding-container {
    display:none; /* will be changed by javascript */
    scale: 1;
    opacity: 1;
    transition:
      scale 0.7s,
      opacity 0.6s;
    background-color: #313D4980;
    border: 4px solid #ffffff00;
    color: #fff;
    border-radius: 12px;
    height: calc(40% - 8px);
    width: calc(38% - 8px);
    top: 20%;
    left: 30%;
    position: fixed;
    text-align: center;
    z-index: 99;
  }

  .onboarding-emoji {
    position: absolute;
    width: 100px;
    rotate: 4deg;
    top: -58px;
    left: -55px;
  }

  .onboarding-content-title,
  .onboarding-content-text,
  .onboarding-content-text-box,
  .onboarding-content-button,
  .onboarding-content-image {
    margin-bottom: 12px;
  }

  .onboarding-content-title {
    font-size: 25px;
    font-weight: 600;
  }

  .onboarding-content-box {
    text-align: left;
    background-color: #525F6C;
    height: calc(100% - 59.7px);
    overflow: auto;
    border-radius: 10px 10px 0px 0px;
    &::-webkit-scrollbar {
      width: 0.5em;
      height: 0.5em;
    }

    &::-webkit-scrollbar-thumb {
      background-color: rgba(255,255,255,.1);
      border-radius: 3px;

    &:hover {
      background: rgba(255,255,255,.2);
    }
    }
  }

  .onboarding-content {
    margin-left: 25px;
    margin-right: 25px;
    margin-top: 14px;
  }

  .onboarding-content-text {
    color: #fff;
    opacity: 0.75;
  }

  .onboarding-content-text-bold {
    color: #fff;
    opacity: 0.75;
    font-weight: 600;
  }

  .onboarding-content-text-dim {
    color: #ffffff50;
  }

  .onboarding-content-text-box {
    background-color: #404d5a65;
    margin-top: 12px;
    border-radius: 12px;
    padding-left: 20px;
    padding-right: 20px;
    padding-top: 12px;
    padding-bottom: 12px;
  }

  .onboarding-controls {
    text-align: right;
    background: #404D5A;
    width: auto;
    height: 59.7px;
    border-radius: 0px 0px 10px 10px;
  }

  /* responsiveness */
  @media screen and (max-width: 599px) {
    .onboarding-container {
      height: calc(94% - 8px);
      width: calc(94% - 8px);
      top: 3%;
      left: 3%;
    }
    
    .onboarding-emoji {
      display: none;
    }
  }
  @media screen and (min-width: 600px) {
    .onboarding-container {
      height: calc(60% - 8px);
      width: calc(58% - 8px);
      top: 20%;
      left: 21%;
    }
    
    .onboarding-emoji {
      position: absolute;
      width: 75px;
      rotate: 4deg;
      top: -38px;
      left: -35px;
    }
  }
  @media screen and (min-width: 1000px) {
    .onboarding-container {
      height: calc(60% - 8px);
      width: calc(48% - 8px);
      top: 20%;
      left: 26%;
    }
    
    .onboarding-emoji {
      position: absolute;
      width: 100px;
      rotate: 4deg;
      top: -58px;
      left: -55px;
    }
  }
  @media screen and (min-width: 1600px) {
    .onboarding-container {
      height: calc(60% - 8px);
      width: calc(38% - 8px);
      top: 20%;
      left: 30%;
    }
  }



  /* button moment */

  .onboarding-controls-button {
    margin-top:9.5px;
    margin-right:9px;
    background-color: #2663EB;
    border: 1px solid transparent;
    border-radius: .5rem;
    box-sizing: border-box;
    color: #FFFFFF;
    cursor: pointer;
    flex: 0 0 auto;
    font-family: "Inter var",ui-sans-serif,system-ui,-apple-system,system-ui,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji";
    font-size: 1.125rem;
    font-weight: 600;
    line-height: 1.5rem;
    padding: .5rem 1.2rem;
    text-align: center;
    text-decoration: none #6B7280 solid;
    text-decoration-thickness: auto;
    transition-duration: 0.2s;
    transition-property: background-color,border-color,color,fill,stroke;
    transition-timing-function: cubic-bezier(.4, 0, 0.2, 1);
    user-select: none;
    -webkit-user-select: none;
    touch-action: manipulation;
    width: auto;
  }

  .onboarding-controls-button:hover {
    background-color: #3B82F6;
  }

  .onboarding-controls-button:focus {
    box-shadow: none;
    outline: 2px solid transparent;
    outline-offset: 2px;
  }



  .onboarding-controls-button-alt {
    margin-top:9.5px;
    margin-right:5px;
    background-color: #606D7B;
    border: 1px solid transparent;
    border-radius: .5rem;
    box-sizing: border-box;
    color: #FFFFFF;
    cursor: pointer;
    flex: 0 0 auto;
    font-family: "Inter var",ui-sans-serif,system-ui,-apple-system,system-ui,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji";
    font-size: 1.125rem;
    font-weight: 600;
    line-height: 1.5rem;
    padding: .5rem 1.2rem;
    text-align: center;
    text-decoration: none #6B7280 solid;
    text-decoration-thickness: auto;
    transition-duration: 0.2s;
    transition-property: background-color,border-color,color,fill,stroke;
    transition-timing-function: cubic-bezier(.4, 0, 0.2, 1);
    user-select: none;
    -webkit-user-select: none;
    touch-action: manipulation;
    width: auto;
  }

  .onboarding-controls-button-alt:hover {
    background-color: #7B8793;
  }

  .onboarding-controls-button-alt:focus {
    box-shadow: none;
    outline: 2px solid transparent;
    outline-offset: 2px;
  }


  .onboarding-content-button {
    background-color: #404d5a;
    border: 0px solid #404d5a;
    border-radius: .5rem;
    box-sizing: border-box;
    color: #ffffff80;
    font-family: "Inter var",ui-sans-serif,system-ui,-apple-system,system-ui,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji";
    font-size: .875rem;
    font-weight: 500;
    line-height: 1.25rem;
    padding: .75rem 1rem;
    text-align: center;
    text-decoration: none #D1D5DB solid;
    text-decoration-thickness: auto;
    box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
    cursor: pointer;
    user-select: none;
    -webkit-user-select: none;
    touch-action: manipulation;
  }

  .onboarding-content-button:hover {
    background-color: #404d5a;
    opacity: 0.8;
  }

  .onboarding-content-button:focus {
    outline: 2px solid transparent;
    outline-offset: 2px;
  }

  .onboarding-content-button:focus-visible {
    box-shadow: none;
  }
</style>