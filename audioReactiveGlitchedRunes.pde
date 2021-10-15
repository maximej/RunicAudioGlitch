
import codeanticode.syphon.*; // import the library
SyphonServer server; // create a syphon server object

import processing.sound.*;


float x1 = 700;
float y1 = 400;
float max = 0.010;
String txt;

Amplitude amp;
AudioIn in;
float ampt;
float amptPrev;
PFont myFont;
PGraphics canvas;
PGraphics pg;
color baseColor = color(128, 0, 0);

void setup() {
  size(1280, 720, P2D); // set the size and the renderer
  // some wired advanced Processing 3 OpenGL setting
  // https://github.com/processing/processing/wiki/Advanced-OpenGL
  PJOGL.profile=1;

  smooth();
  background(255);

  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  in.start();
  amp.input(in);
  background(0, 0, 0, 0);
  canvas = createGraphics(1280, 720, P2D);
  // Create syhpon server to send frames out to other client(s)
  server = new SyphonServer(this, "Processing Syphon");
}

String write() {
  txt = "";
  for (int i=1; i<1024; i++) {
    txt += " " + char( int( random(65, 90) ) );
  }
  return txt;
}

void clearCanvas () {
  canvas.background(0, 0, 0);
  image(canvas, 0, 0);
  canvas.endDraw();
  canvas.beginDraw();
  canvas.loadPixels();
  for (int i = 0; i <= width*height-1; i++) {
    canvas.pixels[i] = color(0, 0, 0, 0);
  }
  canvas.clear();
  canvas.updatePixels();
  image(canvas, 0, 0);
  canvas.endDraw();

  println("Clearing");
}

void glitchCanvas () {

  for (int i = 0; i <= width*height-1; i++) {
    color c = color(canvas.pixels[i]);
    if (random(100)>90 && c != 0) {
      canvas.pixels[i] = color(red(c)+random(80), green(c)+random(80), blue(c)+random(80), 255);
    }
  }
  canvas.updatePixels();


  println("Glitching");
}


void draw() {

  canvas.beginDraw();
  canvas.loadPixels();

  canvas.background(0, 0, 0, 0);

  if (ampt<max && amptPrev>max) {
    clearCanvas();
  };

  amptPrev = ampt;
  ampt = amp.analyze();

  if (ampt>max) {
    if (ampt>max && amptPrev<max) {
      println(); 
      println("In");
    }
    println(ampt);
  }
  
  if (ampt>max && amptPrev>max) {
    glitchCanvas();
  }

  // Function for creatin new runes at the beginning of the trigger
  if (ampt>max && amptPrev<max) {
    myFont = createFont("StandardCelticRune", 128);
    canvas.textFont(myFont);
    canvas.textAlign(CENTER, CENTER);
    canvas.textSize(48);
    canvas.text(write(), 0, 0, width, height);
    canvas.fill(baseColor);
    println("Creating New Runes");
  }
  

  
  canvas.endDraw();

  image(canvas, 0, 0);
  server.sendImage(canvas); // now send all that to client(s)
}
