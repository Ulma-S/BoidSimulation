class Agent {
  PVector position = new PVector(0.0, 0.0);
  PVector moveDir = new PVector(0.0, 0.0);
  PVector avoidDir = new PVector(0.0, 0.0);
  PVector matchDir = new PVector(0.0, 0.0);
  PVector flockDir = new PVector(0.0, 0.0);

  int state = 0;  //0:in, 1:out

  Agent() {
    position.set(random(30.0, width - 30.0), random(30.0, height - 30.0));

    while (true) {
      float xDir = random(-1.0, 1.0);
      float yDir = random(-1.0, 1.0);

      moveDir.set(xDir, yDir);
      moveDir.normalize();
      if (moveDir.mag() != 0.0) break;
    }
  }

  void Draw() {
    fill(255, 0, 0, 100);
    pushMatrix();
    line(position.x, position.y, position.x + moveDir.x * 10.0, position.y + moveDir.y * 10.0);
    ellipse(position.x, position.y, 5, 5);
    popMatrix();
  }

  void Update() {
    moveDir.add(avoidDir);
    moveDir.add(matchDir);
    moveDir.add(flockDir);
  }
  
  void Move(){
    position.add(moveDir.normalize());
  }
}


Agent[] agents = new Agent[52];
void setup() {
  size(400, 400);

  for (int i=0; i<agents.length; i++) {
    agents[i] = new Agent();
  }
}


void draw() {
  background(255);

  CalcAvoidDir(30.0, 2.5);
  CalcMatchDir(0.01);
  CalcFlockDir(0.02);

  for (int i=0; i<agents.length; i++) {
    agents[i].Update();
  }
  
  FixDirection();
  
  for(int i=0; i<agents.length; i++){
    agents[i].Move();
  }

  for (int i=0; i<agents.length; i++) {
    agents[i].Draw();
  }
}


void CalcAvoidDir(float thresholdDistance, float weight) {  
  for (int i=0; i<agents.length; i++) {
    for (int j=0; j<agents.length; j++) {
      if (agents[i] == agents[j]) continue;

      float distance = PVector.dist(agents[i].position, agents[j].position);
      if (distance < thresholdDistance && InWindow(agents[i], 30)) {
        float x = agents[i].position.x - agents[j].position.x;
        float y = agents[i].position.y - agents[j].position.y;
        agents[i].avoidDir.set(x, y);
        agents[i].avoidDir.normalize();
        agents[i].avoidDir.mult(weight);
      }else{
        agents[i].avoidDir.set(0.0, 0.0);
      }
    }
  }
}


void CalcMatchDir(float weight) {
  PVector dirSum = new PVector(0.0, 0.0);

  for (int i=0; i<agents.length; i++) {
    for (int j=0; j<agents.length; j++) {
      if (agents[i] == agents[j]) continue;
      dirSum.add(agents[j].moveDir);
    }
  }

  PVector ave = dirSum.div(agents.length - 1);
  for (int i=0; i<agents.length; i++) {
    float x = ave.x - agents[i].moveDir.x;
    float y = ave.y - agents[i].moveDir.y;    
    agents[i].matchDir.set(x, y);
    agents[i].matchDir.normalize();
    agents[i].matchDir.mult(weight);
  }
}


void CalcFlockDir(float weight) {
  PVector posSum = new PVector(0.0, 0.0);

  for (int i=0; i<agents.length; i++) {
    for (int j=0; j<agents.length; j++) {
      if (agents[i] == agents[j]) continue;
      posSum.add(agents[j].position);
    }
  }

  PVector ave = posSum.div(agents.length - 1);
  for (int i=0; i<agents.length; i++) {
    float x = ave.x - agents[i].position.x;
    float y = ave.y - agents[i].position.y;
    agents[i].flockDir.set(x, y);
    agents[i].flockDir.normalize();
    agents[i].flockDir.mult(weight);
  }
}


void FixDirection() {
  for (int i=0; i<agents.length; i++) {
    PVector toCenter = new PVector(width/2 - agents[i].position.x, height/2 - agents[i].position.y);
    float dot = agents[i].moveDir.dot(toCenter);
    
    switch(agents[i].state) {
    case 0:
      if (!InWindow(agents[i], 40, agents[i].moveDir)) {
        if (dot < 0.0) {
          agents[i].moveDir.rotate(radians(random(0.0, 45.0)));
          //agents[i].state = 1;
        }
      }
      break;

    case 1:
      if (InWindow(agents[i], 30, agents[i].moveDir) && dot > 0) {
        agents[i].state = 0;
      }
      break;
    }
  }
}

boolean InWindow(Agent agent, float margin){
  if(agent.position.x < width-margin && agent.position.x > margin
  && agent.position.y > margin && agent.position.y < height-margin) {
    return true;
  }
  return false;
}

boolean InWindow(Agent agent, float margin, PVector moveDir){
  if(agent.position.x + moveDir.x < width-margin && agent.position.x + moveDir.x > margin
  && agent.position.y + moveDir.y > margin && agent.position.y + moveDir.y < height-margin) {
    return true;
  }
  return false;
}
