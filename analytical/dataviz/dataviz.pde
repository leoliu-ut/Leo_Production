/* @pjs preload="earth.jpg"; */


PImage earth;
PShape globe;

Table table;
String[] cities;//load the table as string

int radius=300;
float angle=0;
float h=5;
PVector raxis;
float s;
float rz;//rotate angel for z axis

HScrollbar hs1;//controller for latitude
HScrollbarv hs2;  // controller for longtitue
Button on_button1; //reset button
Button on_button15;//description

final int SHOWGUI_STATE=0;

final int global_STATE=2;

int state=SHOWGUI_STATE;

void setup() {
  size(900, 960, P3D);
  background(0);
  frameRate(60);
  //create an "Earth"
  noStroke();
  earth = loadImage("earth.jpg");


  //load in table
  table=loadTable("worldcities.csv", "header");

  ////load the csv file as string
  //cities = loadStrings("worldcities.csv");

  //load slider
  hs1 = new HScrollbar(56, height-26, width-106, 16, 20);
  hs2 = new HScrollbarv(26, 56, 16, height-106, 20);

  //load buttons
  on_button1= new Button("reset", 56, 166, 70, 50);
  on_button15= new Button("DATA VIZ - Cities with Population over 100,000", 200, 706, 560, 50);
}


void draw() {
  background(0);
  global();
}




void global() {
  //on_button1.Draw();//sound button
  on_button1.Draw();//reset button

  //sound

  //slider1 rotate along longtitude
  hs1.update();
  hs1.display();

  //slider2 rotate along latitude
  hs2.update();
  hs2.display();

  //description
  textSize(18);
  textAlign(RIGHT);
  text("drag/click the bar to rotate the Earth", width-16, 50);
  text("press up/down arrow to scale the Earth", width-16, 80);



  //center the sphere
  translate(width*0.5, height*0.5);

  //light
  lights();
  fill(255);
  noStroke();

  //load earth
  globe = createShape(SPHERE, radius);
  globe.setTexture(earth);

  //interactivity

  //reset slider
  if (on_button1.MouseIsOver()) {
    hs1 = new HScrollbar(56, height-26, width-106, 16, 20);
    hs2 = new HScrollbarv(26, 56, 16, height-106, 20);
    hs1.reset();
    hs2.reset();
  }

  //scale up/down
  if (keyPressed==true &&keyCode==UP) {
    radius=radius+60;
  } else if (keyPressed==true &&keyCode==DOWN) {
    radius=radius-60;
  }

  //rotate y based on the scroll bar
  rotateY(angle);
  angle =hs1.getPos();
  //rotate z
  rotateX(rz);
  rz =hs2.getPos();

  //load the earth
  shape(globe);

  //  //anther way to read table (as string)
  //for (int i = 1; i < cities.length; i++) {
  //String[] data = cities[i].split(",");
  //  float lat = float(data[2]);
  //float lon = float(data[3]);
  //float mag = float(data[9]);

  //read table
  for ( TableRow row : table.rows()) {

    float lat = row.getFloat("lat");
    float lng = row.getFloat("lng");
    float popu = row.getFloat("population");

    //set location
    float alpha = radians(lat);
    float beta = radians(lng) + PI;
    float xpos = radius * cos(alpha) * cos(beta);
    float ypos = -radius * sin(alpha);
    float zpos = -radius * cos(alpha) * sin(beta);
    PVector loc=new PVector(xpos, ypos, zpos);

    ////normalize population from 10 to 100
    //float popmap = map(popu, 100000, 1887788283, 1, 100);
    //standardize for defaulted method
    float popmapnew= map(popu, 100000, 1887788283, 1, 5);

    //set lgn,lat coordinate onto the sphere
    PVector xaxis= new PVector(1, 0, 0);
    //float angle=PVector.angleBetween(xaxis, loc);
    PVector raxis=xaxis.cross(loc);
    //build 3d viz based on standardized population

    pushMatrix();
    translate(xpos, ypos, zpos);
    rotate(angle, raxis.x, raxis.y, raxis.z);
    fill(#C61414);
    sphere(popmapnew);
    popMatrix();
  }
}

class Button {
  String label; // button label
  float x;      // top left corner x position
  float y;      // top left corner y position
  float w;      // width of button
  float h;      // height of button

  Button(String labelB, float xpos, float ypos, float widthB, float heightB) {
    label = labelB;
    x = xpos;
    y = ypos;
    w = widthB;
    h = heightB;
  }


  //draw button
  void Draw() {
    fill(218);
    stroke(141);
    rect(x, y, w, h, 10);
    textAlign(CENTER, CENTER);
    fill(0);
    textSize(22);
    text(label, x + (w / 2), y + (h / 2));
  }

  //is the mouse over the button?
  boolean MouseIsOver() {
    if (mousePressed==true && mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) {
      return true;
    }
    return false;
  }
}

class HScrollbar {
  float bwidth, bheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  HScrollbar (float xp, float yp, float bw, float bh, int l) {
    bwidth = bw;
    bheight = bh;
    xpos = xp;
    ypos = yp-bheight/2;
    spos = xp+bwidth/2.5;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + bwidth;
    loose = l;
  }

  //display the bar and the slider
  void display() {
    noStroke();
    fill(204);
    rect(xpos, ypos, bwidth, bheight);
    if (over || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, bheight, bheight);
  }

  //mouse control of slider
  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-bheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  //set min/max of the position of the slider
  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  //detect whether mouse is over or not
  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+bwidth &&
      mouseY > ypos && mouseY < ypos+bheight) {
      return true;
    } else {
      return false;
    }
  }

  //get slider position
  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos/bwidth*2.2*PI;
  }

  //reset to the slider to original position
  void reset() {
    spos = xpos+bwidth/2.5;
  }
}

class HScrollbarv {
  float bwidth, bheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // y position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  HScrollbarv (float xp, float yp, float bw, float bh, int l) {
    bwidth = bw;
    bheight = bh;
    xpos = xp-bwidth/2;
    ypos = yp;
    spos = yp;
    newspos = spos;
    sposMin = ypos;
    sposMax = ypos + bheight;
    loose = l;
  }
  //display the bar and the slider
  void display() {
    noStroke();
    fill(204);
    rect(xpos, ypos, bwidth, bheight);
    if (over || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(xpos, spos, bwidth, bwidth);
  }
  //mouse control of slider
  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseY-bwidth/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  //set min/max of the position of the slider
  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  //detect whether mouse is over or not
  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+bwidth &&
      mouseY > ypos && mouseY < ypos+bheight) {
      return true;
    } else {
      return false;
    }
  }

  //get slider position
  float getPos() {
    return (spos/bheight)*2.2*PI;
  }

  //reset to the slider to original position
  void reset() {
    spos = ypos;
  }
}
