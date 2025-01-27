let beef = document.getElementById("audio");
let skinpeeled = document.getElementById("cocaine");
let bone = document.getElementById("name");

let skindex = 0;

let boing = () => {
  let onions = skinpeeled.files[skindex];
  bone.innerHTML = onions.name;
  let tuce = URL.createObjectURL(onions);
  beef.src = tuce;
  beef.play();
}

let play = () => {
  skindex = Math.floor(Math.random() * skinpeeled.files.length);
  boing();
};

let goleft = () => {
  if (skindex <= 0)
    skindex = skinpeeled.files.length;
  skindex -= 1;
  boing();
}

let goright = () => {
  skindex += 1;
  if (skindex >= skinpeeled.files.length)
    skindex = 0;
  boing();
}

beef.addEventListener("ended", function(){
  beef.currentTime = 0;
  play();
});
