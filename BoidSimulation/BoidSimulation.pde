class Agent{
  PVector position = new PVector(0.0, 0.0);
  PVector moveDir = new PVector(0.0, 0.0);
  PVector avoidDir = new PVector(0.0, 0.0);
  PVector matchDir = new PVector(0.0, 0.0);
  PVector flockDir = new PVector(0.0, 0.0);
    
  Agent(){
    position.set(random(0.0, width/3), random(0.0, height/3));
    
    while(true){
      float xDir = random(-1.0, 1.0);
      float yDir = random(-1.0, 1.0);
      
      moveDir.set(xDir, yDir);
      moveDir.normalize();
      if(moveDir.mag() != 0.0) break;
    }
  }
  
  void Draw(){
    fill(255, 0, 0, 100);
    pushMatrix();
    ellipse(position.x, position.y, 5, 5);
    popMatrix();
  }
  
  void Update(){
    moveDir.add(avoidDir);
    //moveDir.add(matchDir);
    //moveDir.add(flockDir);
    println(moveDir.normalize());
    FixPosition();
    position.add(moveDir.normalize());
  }
}


Agent[] agents = new Agent[10];
void setup(){
 size(400, 400);
 
 for(int i=0; i<agents.length; i++){
   agents[i] = new Agent();
 }
}


void draw(){
  background(255);
  
  CalcAvoidDir(30.0, 0.1);
  CalcMatchDir(0.1);
  CalcFlockDir(1);
  
  for(int i=0; i<agents.length; i++){
    agents[i].Update();
  }
  
  FixPosition();

  for(int i=0; i<agents.length; i++){
    agents[i].Draw();
  }
}


void CalcAvoidDir(float thresholdDistance, float weight){  
  for(int i=0; i<agents.length; i++){
    for(int j=0; j<agents.length; j++){
      if(agents[i] == agents[j]) continue;
    
      float distance = PVector.dist(agents[i].position, agents[j].position);
      if(distance < thresholdDistance){
        float x = agents[i].position.x - agents[j].position.x;
        float y = agents[i].position.y - agents[j].position.y;
        agents[i].avoidDir.set(x, y);
        agents[i].avoidDir.mult(weight);
      }
    }
  }
}


void CalcMatchDir(float weight){
  PVector dirSum = new PVector(0.0, 0.0);
  
  for(int i=0; i<agents.length; i++){
    for(int j=0; j<agents.length; j++){
      if(agents[i] == agents[j]) continue;
      dirSum.add(agents[j].moveDir);
    }
  }
  
  PVector ave = dirSum.div(agents.length - 1);
  for(int i=0; i<agents.length; i++){
    float x = ave.x - agents[i].moveDir.x;
    float y = ave.y - agents[i].moveDir.y;
    agents[i].matchDir.set(x, y);
    agents[i].matchDir.mult(weight);
  }
}


void CalcFlockDir(float weight){
  PVector posSum = new PVector(0.0, 0.0);
  
  for(int i=0; i<agents.length; i++){
    for(int j=0; j<agents.length; j++){
      if(agents[i] == agents[j]) continue;
      posSum.add(agents[j].position);
    }
  }
  
  PVector ave = posSum.div(agents.length - 1);
  for(int i=0; i<agents.length; i++){
    float x = ave.x - agents[i].position.x;
    float y = ave.y - agents[i].position.y;
    agents[i].flockDir.set(x, y);
    agents[i].flockDir.mult(weight);
  }
}


void FixPosition(){
  for(int i=0; i<agents.length; i++){
    if(agents[i].position.x <= width && agents[i].position.x >= 0
      && agents[i].position.y >= 0 && agents[i].position.y <= height) {
      continue;
    }
    PVector toCenter = new PVector(width/2 - agents[i].position.x, height/2 - agents[i].position.y);
    float dot = agents[i].moveDir.dot(toCenter);
    if(dot <= 0.0){
      agents[i].moveDir.mult(-1.0);
      agents[i].inRange = true;
    }
  }
}
                                   