<script lang="ts">

</script>

<div class="loading fadeOut">
  <div class="cloud"></div>
  <div class="data">
    <span>0</span>
    <span>1</span>
    <span>0</span>
    <span>1</span>
    <span>0</span>
    <span>1</span>
    <span>0</span>
  </div>
  <div class="browser">
    <div class="buttons"></div>
  </div>
</div>

<style>
.fadeOut {
    width:200px;
    height: 200px;
    -webkit-animation: fadeinout 4s linear forwards;
    animation: fadeinout 4s linear forwards;
}

@keyframes fadeinout {
  0%,100% { opacity: 0; }
  50% { opacity: 1; }
}

.loading {
  position: relative;
  top: 30vh;
  width: 500px;
  height: 120px;
  margin: 0 auto;
  opacity: .7;
}
.loading .cloud {
  position: absolute;
  top: 50px;
  left: 10px;
  width: 170px;
  height: 60px;
  border-radius: 25%/75%;
  background-color: #ddd;
  animation: pulse 2500ms;
  animation-iteration-count: infinite;
  z-index: 1;
}
.loading .cloud:before {
  content: " ";
  position: absolute;
  top: -23px;
  left: 25px;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background-color: #ddd;
}
.loading .cloud:after {
  content: " ";
  position: absolute;
  top: -40px;
  left: 60px;
  width: 90px;
  height: 90px;
  border-radius: 50%;
  background-color: #ddd;
}
.loading .data {
  font-family: monospace;
  position: absolute;
  top: 60px;
  left: 120px;
  z-index: 0;
}
.loading .data > span {
  display: inline-block;
  animation: flyby 2.5s;
  animation-iteration-count: infinite;
  transform: translate(0, 0);
  padding: 3px;
}
.loading .data > span:nth-child(7) {
  animation-delay: 140ms;
}
.loading .data > span:nth-child(6) {
  animation-delay: 280ms;
}
.loading .data > span:nth-child(5) {
  animation-delay: 420ms;
}
.loading .data > span:nth-child(4) {
  animation-delay: 560ms;
}
.loading .data > span:nth-child(3) {
  animation-delay: 700ms;
}
.loading .data > span:nth-child(2) {
  animation-delay: 840ms;
}
.loading .data > span:nth-child(1) {
  animation-delay: 980ms;
}
.loading .browser {
  position: absolute;
  right: 0px;
  top: 10px;
  width: 140px;
  height: 100px;
  border-radius: 4px;
  background-color: #aaa;
  z-index: 1;
}
.loading .browser:before {
  content: " ";
  position: absolute;
  height: 78px;
  bottom: 2px;
  left: 2px;
  right: 2px;
  border-radius: 0 0 2px 2px;
  opacity: 0.9;
  background-color: white;
  z-index: 2;
}
.loading .browser:after {
  content: " ";
  position: absolute;
  height: 78px;
  bottom: 2px;
  left: 2px;
  right: 2px;
  border-radius: 0 0 2px 2px;
  opacity: 0.9;
  background-color: #8cb6d8;
  z-index: 2;
  animation: fill 2.5s;
  animation-iteration-count: infinite;
}
.loading .browser .buttons {
  display: inline-block;
  position: absolute;
  left: 20px;
  top: 5px;
  float: left;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: #ffc107;
  opacity: 0.8;
}
.loading .browser .buttons:before {
  content: " ";
  display: inline-block;
  position: absolute;
  left: -15px;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: #f44336;
}
.loading .browser .buttons:after {
  content: " ";
  display: inline-block;
  position: absolute;
  left: 15px;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: #4caf50;
}

@keyframes pulse {
  7% {
    transform: scale(1, 1);
  }
  14% {
    transform: scale(1.1, 1.1);
  }
  30% {
    transform: scale(1, 1);
  }
}
@keyframes fill {
  0% {
    height: 0px;
    opacity: 1;
  }
  35% {
    height: 0px;
  }
  89% {
    height: 78px;
  }
  89% {
    opacity: 1;
  }
  100% {
    opacity: 0;
  }
}
@keyframes flyby {
  0% {
    transform: translate(0px, 0);
    opacity: 1;
    animation-timing-function: ease-out;
  }
  7% {
    transform: translate(60px, 0);
    animation-timing-function: linear;
  }
  30% {
    transform: translate(80px, 0);
    animation-timing-function: linear;
  }
  40% {
    transform: translate(230px, 0);
    animation-timing-function: ease-out;
  }
  60% {
    transform: translate(240px, 0);
    animation-timing-function: ease-out;
  }
  100% {
    transform: translate(240px, 0);
    opacity: 0;
  }
}
</style>