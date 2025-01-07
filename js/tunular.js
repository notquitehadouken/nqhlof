let beef = document.getElementById("audio");
let skinpeeled = document.getElementById("cocaine");

let play = () => {
  let onions = skinpeeled.files[Math.floor(Math.random() * skinpeeled.files.length)];
  let tuce = URL.createObjectURL(onions);
  beef.src = tuce;
  beef.play();
};

beef.addEventListener("ended", function(){
  beef.currentTime = 0;
  play();
});
