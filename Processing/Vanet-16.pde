

////////////////////////////////////////////////////////////////////////////////

//   VANET System Monitor
//   Copyright (c) 2016 Vishnu M Aiea
//   E-Mail : vishnumaiea@gmail.com
//   Web : www.vishnumaiea.in
//   Date created : 9:45 AM, 13-03-2015, Friday
//   Last modified : 10:43 AM 21-04-2015, Tuesday

////////////////////////////////////////////////////////////////////////////////

import processing.serial.*;

//Global Variables

Serial serialPort;

final int frameWidth = 800;
final int frameHeight = 650;

int portValue = 0; //virtual com port value
int mouseStatus = 0; //status of mouse input
int obuDistance = 5; //total distance covered by OBU
int tempInt; //int variable for testing
int comStatusCounter; //to check is the OBU is on and transmitting

float accelX; //acceleration on X
float accelY; //acceleration on Y
float accelZ; //acceleration on Z
float obuLongitude; //GPS longitude
float obuLatitude; //GPS latitude
float prevLongitude; //previous longitude value
float prevLatitude; //previous latitude value
float holdLongitude; //holds the longitude value
float holdLatitude; //holds the latitude value
float obuSpeed; //vehicle speed

boolean startPressed = false; //for start button
boolean quitPressed = false; //for quit button
boolean serialSuccess = false; //check if com port opening was successful
boolean portError = false; //port error status

String portName = "None"; //name of port selected
String serialBuffer; //string that holds read serial data
String tempString; //string variable for testing
String longDirection; //Longitude direction
String latDirection; //Latitude direction
String holdLongDirection = "U";
String holdLatDirection = "U";
String obuDirection = "None";
String obuLongitudeString;
String obuLatitudeString;
String comStatus = "Disconnected";

color boxColor_start = #FFFFFF; //start button color
color boxColor_quit = #FFFFFF; //quit button color
color boxColor_about = #FFFFFF;
color textColor_start = #006699; //start button text color
color textColor_quit  = #006699; //quit button txt color
color textColor_about = #006699; //about text font

PFont buttonFont; //font for button
PFont aboutFont; //font for about
PFont aboutTitleFont;
PFont titleFont; //font for bingo title
PFont nameFont; //font for names

////////////////////////////////////////////////////////////////////////////////

void setup()//Initialization
{
  size(800,650); //frame size
  background(170); //default bg colour
  frame.setTitle("VANET System Monitor by Vishnu M Aiea"); //app title
  //frame.setIconImage( getToolkit().getImage("sketch.ico") );
  buttonFont = loadFont("Calibri-18.vlw"); //font for the button
  aboutFont = loadFont("Verdana-20.vlw");
  aboutTitleFont = loadFont("Corbel-Bold-48.vlw"); //font for about
  titleFont = loadFont("Aharoni-Bold-48.vlw"); //title font
  nameFont = loadFont("Corbel-Bold-48.vlw"); //names font
}

////////////////////////////////////////////////////////////////////////////////

void draw()
{
  if (!startPressed) //if app not started
  {
    smooth();
    noStroke();

    fill(220);
    rect(125, 450, 550, 100);//small box at bottom

    fill(boxColor_start); //start box color
    rect(260, 480, 80, 35); //start box
    fill(boxColor_quit); //quit box color
    rect(460, 480, 80, 35); //quit box

    //textMode(SHAPE);
    textFont(buttonFont, 18);
    fill(textColor_start); //start box text color
    text("Start", 280, 503);
    fill(textColor_quit); //quit box text color
    text("Quit", 482, 503);

    //if quit button pressed
    if (mouseX>=460 && mouseX<=540 && mouseY>=480 && mouseY<=515)
    {
      if (mousePressed && (mouseButton == LEFT))
      {
        exit(); //quit application
      }
      boxColor_quit = #006699; //complement quit box colors
      textColor_quit = #FFFFFF;
    } else
    {
      boxColor_quit = #FFFFFF; //reset colors
      textColor_quit = #006699;
    }

    //if start button pressed
    if (mouseX>=260 && mouseX<=340 && mouseY>=480 && mouseY<=515)
    {
      if (mousePressed && (mouseButton == LEFT) && (mouseStatus == 0))
      {
        startPressed = true;
        mouseStatus = 1;
      }
      if (!mousePressed)
      {
        mouseStatus = 0;
      }
      boxColor_start = #006699; //complement start box colors
      textColor_start = #FFFFFF;
    } else //reset color
    {
      boxColor_start = #FFFFFF;
      textColor_start = #006699;
    }
    //--------------------------------------------------------------------------

    //about box
    fill(boxColor_about);
    rect(125, 100, 550, 350); //large box
    fill(textColor_about);
    rect(125, 100, 550, 100); //small box w/t title

    textFont(aboutTitleFont, 34);
    //fill(textColor_about);
    fill(#FFFFFF);
    text("VANET SYSTEM MONITOR", 205, 155);

    textFont(aboutFont, 12);
    fill(200);
    text("Copyright © 2015 Vishnu M Aiea", 310, 185);

    fill(textColor_about);
    textFont(aboutFont, 14);
    text("Connect the RSU and select the COM port", 260, 370);

    rect(340, 270, 120, 40); //COM port selection
    fill(#FFFFFF);
    rect(370, 272, 60, 36); //small rect for port value

    textFont(aboutFont, 22);
    fill(#FFFFFF);
    text("<", 347, 298); //port select arrow kyes
    text(">", 437, 298);

    if (portError) //only if the selected port is not found
    {
      fill(#B70F0F);
      textFont(aboutFont, 13);
      text("Error : Could not find the port specified !", 270, 400);
    }

    textFont(aboutFont, 12);
    fill(#000000); //com port value color
    //text("COM", 377, 298);

    if (Serial.list().length > 0) //check if there is any port
    {
      //decrement com port value
      if (mouseX>=340 && mouseX<=370 && mouseY>=270 && mouseY<=310)
      {
        if (mousePressed && (mouseButton == LEFT) && (mouseStatus == 0))
        {
          if (portValue > 0)
          {
            portValue--;
            portName = Serial.list()[portValue];
            mouseStatus = 1;
          }
        }
        if (!mousePressed)
        {
          mouseStatus = 0; //so that there is no indefinite decrement
        }
      }
      
      else
      {
        portValue = 0;
      }

      //increment com port value
      if (mouseX>=430 && mouseX<=460 && mouseY>=270 && mouseY<=310)
      {
        if (mousePressed && (mouseButton == LEFT) && (mouseStatus == 0))
        {
          if (portValue < (Serial.list().length -1 ))
          {
            portValue++;
            mouseStatus = 1;
          }
        }
        if (!mousePressed)
        {
          mouseStatus = 0; //so that there is no indefinite increment
        }
      }
      
      else
      {
        portValue = 0;
      }

      portName = Serial.list()[portValue]; //get the port name now selected
      text(portName, 380, 298); //then print it
    } else
    {
      text("None", 380, 298);
    }
  }
  //-----------------------------------------------------------------------------

  if (startPressed)
  {   
    //Establish Serial Connection

    if (!serialSuccess)
    {
      if (Serial.list().length > 0)//port value should be greater than 2 and <= to total no. of ports + 2
      {
        portName = Serial.list()[portValue]; //because can't use COM1 and COM2
        serialPort = new Serial(this, portName, 9600);
        println("Serial Communication Established");
        println("Listing ports");
        println(Serial.list()); //list the available ports
        println();
        print("Selected Port is ");
        println(portName); //print selected port name
        print("portValue = ");
        println(portValue); //print the port value use selected
        print("Total no. of ports = ");
        println(Serial.list().length); //total no. of ports
        serialSuccess = true;
      } else
      {
        println("Error : Could not find the port specified");
        background(170);
        portError = true; //error opening the port
        serialSuccess = false; //serial com error
        startPressed = false; //causes returning to home screen
      }
    }
    //---------------------------------------------------------------------------

    //Display the layout

    if (serialSuccess && (Serial.list().length) > 0 && (portName.equals(Serial.list()[portValue])))
    {
      background(200);
      fill(textColor_about);
      rect(0, 0, 800, 65); //rect for title

      smooth();
      noStroke();
      textFont(aboutTitleFont, 28);
      fill(250);
      text("VANET SYSTEM MONITOR", 240, 40); //title

      //secondary rectangles
      fill(250);
      rect(30, 100, 300, 290); //graph
      rect(30, 420, 300, 210); //acceleration
      rect(360, 100, 410, 170); //com status
      rect(360, 300, 410, 330); //speed

      //subtitle rectangles
      fill(textColor_about);
      rect(30, 100, 300, 25); //graph
      rect(30, 420, 300, 25); //acceleration
      rect(360, 100, 410, 25); //com status
      rect(360, 300, 410, 25); //speed

      //sub-titles
      textFont(aboutFont, 13);
      fill(250);
      text("Graph", 45, 117);
      text("Acceleration", 45, 437);
      text("Communication Status", 370, 117);
      text("Transit Information", 370, 317);

      //parameter names
      fill(textColor_about);
      textFont(aboutFont, 13);
      text("Clients Connected", 400, 165);
      text("Total Polled", 400, 200);
      text("Status", 400, 236);

      text("Longitude", 400, 365);
      text("Latitude", 400, 415);
      text("Status", 400, 465);
      text("Speed", 400, 515);
      text("Direction", 400, 565);
      text("Distance Covered", 400, 610);

      text("Acceleration - X", 60, 480);
      text("Acceleration - Y", 60, 520);
      text("Acceleration - Z", 60, 560);
      text("Freefall", 60, 600);

      //value boxes
      fill(230);
      rect(540, 147, 190, 25);//com status
      rect(540, 183, 190, 25);
      rect(540, 219, 190, 25);

      rect(540, 345, 190, 28);//speed
      rect(540, 394, 190, 28);
      rect(540, 443, 190, 28);
      rect(540, 492, 190, 28);
      rect(540, 543, 190, 28);
      rect(540, 590, 190, 28);

      rect(180, 460, 130, 28);//acceleration
      rect(180, 500, 130, 28);
      rect(180, 540, 130, 28);
      rect(180, 580, 130, 28);
      //-------------------------------------------------------------------------

      //Start Serial Communication and Display Data

      textFont(aboutFont, 10);
      fill(250);
      text(portName, 720, 117); //show selected port name


      if (serialPort.available() > 0)
      {
        serialBuffer = serialPort.readStringUntil(','); //because values are separated my commas
        if (serialBuffer != null)
        {
          //println(serialBuffer);
          if (serialBuffer.equals("longitude,")) //Longitude
          {
            //println(serialBuffer);
            serialBuffer = serialPort.readStringUntil(',');
            if (serialBuffer != null)
            {
              //println(serialBuffer);
              //tempString = serialBuffer.substring(0, (serialBuffer.length()-1));
              //tempInt = int(tempString);
              //tempInt = tempInt + 1;
              //println(tempInt);
              tempString = serialBuffer.substring(0, (serialBuffer.length()-1)); //removing comma
              obuLongitude = float(tempString);//tempString is used as a temp buffer

              if (tempString.length() > 3)
              {
                tempString = serialBuffer.substring(1, (serialBuffer.length()-1));
                String[] splittedString = split(tempString, '.');
                //firstHalfString = 
                //println(splittedString[0]);
                //println(splittedString[1]);
                String firstHalfString = str(((float(splittedString[0])) / 100));
                //println(firstHalfString);
                String secondHalfString = splittedString[1];
                tempString = firstHalfString + secondHalfString;
                //println(tempString);
                obuLongitudeString = tempString;
                //println(tempString);
              }
            }
          } else if (serialBuffer.equals("longDirection,")) //Latitude
          {
            //println(serialBuffer);
            serialBuffer = serialPort.readStringUntil(',');
            if (serialBuffer != null)
            {
              //println(serialBuffer);
              tempString = serialBuffer.substring(0, (serialBuffer.length()-1));
              longDirection = tempString; //convert string to int value
              //println(tempString);
            }
          } else if (serialBuffer.equals("latitude,")) //Latitude
          {
            //println(serialBuffer);
            serialBuffer = serialPort.readStringUntil(',');
            if (serialBuffer != null)
            {
              //println(serialBuffer);
              tempString = serialBuffer.substring(0, (serialBuffer.length()-1));
              obuLatitude = float(tempString); //convert string to int value
              //println(tempString);
              if (tempString.length() > 3)
              {
                tempString = serialBuffer.substring(1, (serialBuffer.length()-1));
                String[] splittedString = split(tempString, '.');
                String firstHalfString = str(((float(splittedString[0])) / 100));
                String secondHalfString = splittedString[1];
                tempString = firstHalfString + secondHalfString;
                obuLatitudeString = tempString;
              }
            }
          } else if (serialBuffer.equals("latDirection,")) //Latitude
          {
            //println(serialBuffer);
            serialBuffer = serialPort.readStringUntil(',');
            if (serialBuffer != null)
            {
              //println(serialBuffer);
              tempString = serialBuffer.substring(0, (serialBuffer.length()-1));
              latDirection = tempString; //convert string to int value
              //println(tempString);
            }
          } else if (serialBuffer.equals("speed,")) //Vehicle speed
          {
            //println(serialBuffer);
            serialBuffer = serialPort.readStringUntil(',');
            if (serialBuffer != null)
            {
              //println(serialBuffer);
              tempString = serialBuffer.substring(0, (serialBuffer.length()-1));
              obuSpeed = float(tempString);
            }
          } else if (serialBuffer.equals("accelx,")) //Acceleration on X
          {
            //println(serialBuffer);
            serialBuffer = serialPort.readStringUntil(',');
            if (serialBuffer != null)
            {
              //println(serialBuffer);
              tempString = serialBuffer.substring(0, (serialBuffer.length()-1));
              accelX = float(tempString);
              //println(accelX);
            }
          } else if (serialBuffer.equals("accely,")) //Acceleration on Y
          {
            //println(serialBuffer);
            serialBuffer = serialPort.readStringUntil(',');
            if (serialBuffer != null)
            {
              //println(serialBuffer);
              tempString = serialBuffer.substring(0, (serialBuffer.length()-1));
              accelY = float(tempString);
            }
          } else if (serialBuffer.equals("accelz,")) //Acceleration on Z
          {
            //println(serialBuffer);
            serialBuffer = serialPort.readStringUntil(',');
            if (serialBuffer != null)
            {
              //println(serialBuffer);
              tempString = serialBuffer.substring(0, (serialBuffer.length()-1));
              accelZ = float(tempString);
            }
          }
        }
        comStatus = "Receiving";
        comStatusCounter = 0; //reset the counter
      } else //it's like a watchdog timer
      {
        comStatusCounter++; //start counting

        if (comStatusCounter > 70)
        {
          comStatus = "No Reception"; //if there is no com for sometime
        }
      }
      //------------------------------------------------------------------------

      //Display the values

      textFont(aboutFont, 12);
      fill(30);
      if (!Float.isNaN(obuLongitude)) //if only not NaN
      {
        if (holdLongitude == 0) //initial value of holdLongitude is 0
        {
          text("Acquiring", 600, 364); //so print acquiring
        } else
        {
          text(obuLongitudeString, 600, 364); //else show Longitude value
        }

        holdLongitude = obuLongitude; //save or hold the value
      } else //if obuLongitude is NaN
      {
        if (holdLongitude == 0)
        {
          text("Acquiring", 600, 364); //if it is 0
        } else
        {
          text(obuLongitudeString, 600, 364); //else print the last saved value
        }
      }

      if (longDirection != null && (longDirection.equals("E") || longDirection.equals("W"))) //longitude direction
      {
        text(holdLongDirection, 692, 364);
        holdLongDirection = longDirection;
      } else
      {
        //text("U", 670, 364); //no direction
        text(holdLongDirection, 692, 364);
      }

      if (!Float.isNaN(obuLatitude)) //if only not NaN
      {
        if (holdLatitude == 0)
        {
          text("Acquiring", 600, 414); //if last saved value is zero
        } else
        {
          text(obuLatitudeString, 600, 414); //else show Latitude value
        }

        holdLatitude = obuLatitude; //save or hold the last acquired value
      } else //if obuLatitude is NaN
      {
        if (holdLatitude == 0)
        {
          text("Acquiring", 600, 414); //print this if it is 0
        } else
        {
          text(obuLatitudeString, 600, 414); //else show the saved Latitude value
        }
      }

      if (latDirection != null && (latDirection.equals("S") || latDirection.equals("N"))) //latitude direction
      {
        text(holdLatDirection, 692, 414);
        holdLatDirection = latDirection;
      } else
      {
        //text("U", 670, 414);
        text(holdLatDirection, 692, 414);
      }

      if (obuSpeed < 0.1) //vehicle transit status
      {
        text("Static", 600, 463);
      } else if (obuSpeed >= 0.1)
      {
        text("Moving Slow", 600, 463);
      } else if (obuSpeed >= 1 )
      {
        text("Moving", 600, 463);
      } else if (obuSpeed >=5)
      {
        text("Moving Fast", 600, 463);
      } else
      {
        text("Static", 600, 463);
      }


      //println(obuSpeed);
      if (!Float.isNaN(obuSpeed)) //if not NaN
      {
        text(obuSpeed * 1.852, 600, 512); //show the vehicle speed
      } else
      {
        text("0.000", 600, 512); //else show 0
      }

      text("km/hr", 655, 512); //the unit for speed

      if (obuSpeed >= 0.1) //detect and print vehicle direction
      {
        text(obuDirection, 600, 563);

        //if (!Float.isNaN(obuLongitude) && !Float.isNaN(obuLatitude))
        
        if (prevLongitude > obuLongitude)
        {
          obuDirection = "East";
          //text("East", 600, 563);
          prevLongitude = obuLongitude;
        } else if (prevLongitude < obuLongitude)
        {
          obuDirection = "West";
          //text("West", 600, 563);
          prevLongitude = obuLongitude;
        } else if (prevLatitude > obuLatitude)
        {
          obuDirection = "North";
          //text("North", 600, 563);
          prevLatitude = obuLatitude;
        } else if (prevLatitude < obuLatitude)
        {
          obuDirection = "South";
          //text("South", 600, 563);
          prevLatitude = obuLatitude;
        }
      } else
      {
        text("None", 600, 563);
      }


      text(obuDistance, 600, 609); //show the distance covered
      text("meters", 640, 609); //the unit for distance

      text(accelX * 9.8, 205, 480); //show acceleration X
      text("m/s", 265, 480);

      text(accelY * 9.8, 205, 520); //show acceleration Y
      text("m/s", 265, 520);

      text(accelZ * 9.8, 205, 560); //show acceleration Z
      text("m/s", 265, 560);

      textFont(aboutFont, 9); //superscript 2 for accelration
      text("2", 290, 475); //X
      text("2", 290, 515); //Y
      text("2", 290, 555); //Z

      textFont(aboutFont, 12); //reset font to default

      text("False", 228, 600); //print freefall status

      text("1", 620, 165); //total clients connected
      text("1", 620, 200); //total polled
      text(comStatus, 600, 235); //com status
      
      //-----------------------------------------------------------------------------
      //Draw the graph
      //rect(30, 100, 300, 290); //graph
      //rect(30, 100, 300, 25); //graph
      //fill(#006699);
      
      stroke(200);
      noFill();
      ellipse(180, 255, 200, 200);
      
      stroke(200);
      strokeWeight(0.5);
      line(30, 125, 329, 125);
      line(30, 155, 329, 155);
      line(30, 185, 329, 185);
      line(30, 215, 329, 215);
      line(30, 245, 329, 245);
      line(30, 275, 329, 275);
      line(30, 305, 329, 305);
      line(30, 335, 329, 335);
      line(30, 365, 329, 365);
      
      line(60, 125, 60, 390);
      line(90, 125, 90, 390);
      line(120, 125, 120, 390);
      line(150, 125, 150, 390);
      line(180, 125, 180, 390);
      line(210, 125, 210, 390);
      line(240, 125, 240, 390);
      line(270, 125, 270, 390);
      line(300, 125, 300, 390);
      
      
      noStroke();
      fill(#CE283E);
      ellipse(180, 255, 15, 15); //Range Limit Circle
      
      fill(#18CB02);
      ellipse(230, 280, 15, 15); //Green Circle
      fill(#1982B4);
      ellipse(100, 200, 15, 15); //Blue Circles
      ellipse(160, 340, 15, 15);
      
      textFont(aboutFont, 11);
      fill(30);
      text("N", 177, 145);
      text("S", 177, 383);
      text("W", 37, 259);
      text("E", 312, 259);
      
    } 
    else //if you discoonect the device after establishing connection
    {
      background(170);
      serialSuccess = false;
      portError = true;
      startPressed = false;
    }
  }
}

//////////////////////////////////////////////////////////////////////////////
