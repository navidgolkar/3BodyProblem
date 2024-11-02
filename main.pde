float min_mass=1, max_mass=7;
float size_factor = 1/min_mass;

class Body {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass;
  float angle;
  float angularVelocity;
  ArrayList<PVector> lastpos = new ArrayList<PVector>();
  boolean isSun = false;
  
  Body(float x, float y, float mass, float vx, float vy, boolean sun) {
    isSun = sun;
    position = new PVector(x, y);
    velocity = new PVector(vx, vy);
    acceleration = new PVector(0, 0);
    this.mass = mass;
    angle = 0;
    angularVelocity = 0;
  }
  
  void applyForce(PVector force) {
    if (!isSun) {
      PVector f = PVector.div(force, mass);
      acceleration.add(f);
    }
  }

  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
    angle += angularVelocity;
    if (!isSun) {
      /*if (position.x > width) {
        position.x=0;
        lastpos.clear();
      } else if (position.x < 0) {
        position.x=width;
        lastpos.clear();
      }
      if (position.y > height) {
        position.y=0;
        lastpos.clear();
      } else if (position.y < 0) {
        position.y=height;
        lastpos.clear();
      }*/
      PVector pos = new PVector(position.x, position.y);
      lastpos.add(pos);
      if (lastpos.size() > 10) lastpos.remove(0);
    }
    
  }

  void display() {
    if (isSun) {
      noStroke();
      fill(255, 0, 0);
      ellipse(position.x, position.y, mass*size_factor, mass*size_factor);
    }
    else {
      stroke(0);
      strokeWeight(2);
      noFill();
      ellipse(position.x, position.y, mass*size_factor, mass*size_factor);
      strokeWeight(1);
      noFill();
      stroke(0, 0, 255); // blue color
      beginShape();
      for (PVector pos : lastpos) {
        vertex(pos.x, pos.y);
      }
      endShape();
    }
  }
}

Body[] bodies = new Body[4];
float G = 6.67430e-11; // gravitational constant

void setup() {
  size(800, 800);
  bodies[0] = new Body((float)width/2, (float)height/2, 5*max_mass, 0, 0, true);
  for (int i = 1; i < bodies.length; i++) {
    float r = map(i, 1, bodies.length-1, width/5, 0.8*width/2.0);
    float x = (float)(width/2 + r*Math.cos(i*2*Math.PI/(bodies.length-1)));
    float y = (float)(height/2 + r*Math.sin(i*2*Math.PI/(bodies.length-1)));
    float mass = map(i, 1, bodies.length, min_mass, max_mass);
    float vx = (float)(3*Math.cos(i*2*Math.PI/(bodies.length-1) + Math.PI/2));
    float vy = (float)(3*Math.sin(i*2*Math.PI/(bodies.length-1) + Math.PI/2));
    bodies[i] = new Body(x, y, mass, vx, vy, false);
  }
}

void draw() {
  background(255);
  for (int i = 0; i < bodies.length; i++) {
    for (int j = i+1; j < bodies.length; j++) {
      PVector force = calculateForce(bodies[i], bodies[j]);
      bodies[i].applyForce(force);
      bodies[j].applyForce(force.mult(-1));
    }
  }

  for (int i = 0; i < bodies.length; i++) {
    bodies[i].update();
    bodies[i].display();
  }
}

PVector calculateForce(Body b1, Body b2) {
  PVector force = PVector.sub(b2.position, b1.position);
  float distance = force.mag();
  force.normalize();

  // Gravitational force
  float strength = (G * b1.mass * b2.mass * pow(10, 12)) / (distance * distance);
  force.mult(strength);

  // Torque due to gravitational force
  PVector dir = PVector.sub(b2.position, b1.position);
  float torque = strength * distance * sin(force.heading() - dir.heading());
  float angularAcceleration = torque / b1.mass; // Assuming the body rotates around its center of mass
  b1.angularVelocity += angularAcceleration;

  return force;
}
