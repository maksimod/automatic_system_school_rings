import controlP5.*; // Подключаем графическую библиотеку
import processing.serial.*;
Serial serial; // Для подключения к МК

ControlP5 cp5;
 
int max_day_l_count = 20;
String portName;

boolean AUTOFILLING = true;

PrintWriter output; //Для экспорта и импорта файлов

boolean is_imp = false;

void setup() {
  frameRate(60);
  size(1150,650);
  surface.setLocation(0,0);
  PFont font = createFont("arial",20);
  cp5 = new ControlP5(this);
  // Добавляем графические элементы
  int scmechene = 120;
  int counter = 0;
 
  cp5.addTextlabel("M")
      .setText("Monday")
      .setPosition(30+scmechene*counter,10)
      .setColorValue(255)
      .setFont(createFont("Georgia",20))
      ;
  counter+=1;                  
  cp5.addTextlabel("Tu")
      .setText("Tuesday")
      .setPosition(30+scmechene*counter,10)
      .setColorValue(255)
      .setFont(createFont("Georgia",20))
      ;
  counter+=1;   
  cp5.addTextlabel("W")
      .setText("Wednesday")
      .setPosition(30+scmechene*counter,10)
      .setColorValue(255)
      .setFont(createFont("Georgia",20))
      ;
counter+=1;   
  cp5.addTextlabel("Th")
      .setText("Thursday")
      .setPosition(30+scmechene*counter,10)
      .setColorValue(255)
      .setFont(createFont("Georgia",20))
      ;
  counter+=1;   
  cp5.addTextlabel("F")
      .setText("Friday")
      .setPosition(30+scmechene*counter,10)
      .setColorValue(255)
      .setFont(createFont("Georgia",20))
      ;
  counter+=1;   
  cp5.addTextlabel("Sat")
      .setText("Saturday")
      .setPosition(30+scmechene*counter,10)
      .setColorValue(255)
      .setFont(createFont("Georgia",20))
      ;   
                    
  counter+=1;   
  cp5.addTextlabel("Sun")
      .setText("Sunday")
      .setPosition(30+scmechene*counter,10)
      .setColorValue(255)
      .setFont(createFont("Georgia",20))
      ;   

                    
    for (int i = 1; i<=max_day_l_count;i++){     
  cp5.addTextlabel("LD"+str(i))
      .setText(str(i))
      .setPosition(5,40-30+i*29)
      .setColorValue(255)
      .setFont(createFont("Georgia",20))
      ;
    }
  // Добавляем поля ввода звонков
  int vert_offset = 29;
  counter = 0;
  for (int i = 0; i<7;i++){
    for (int k = 0; k<max_day_l_count;k++){
      cp5.addTextfield("R"+str(counter))
         .setPosition(40+i*scmechene,40+k*vert_offset)
         .setSize(50,25)
         .setFont(font)
         .setFocus(((i==0)&(k==0)))
         .setColor(color(255))
         .setAutoClear(false)
         ;
       counter+=1;
    }
  }
  int init = 10;
  int offset = 260;
  // добавляем кнопку отправить
  cp5.addButton("submit")
      .setPosition(width-offset,init)
      .setColorValue(255)
      .setFont(createFont("Georgia",20))
      .setSize(80,30);
      ;
// добавляем кнопку очистить
  cp5.addButton("clear")
      .setPosition(width-offset,init+40)
      .setColorValue(255)
      .setFont(createFont("Georgia",20))
      .setSize(80,30);
      ;                    
  cp5.addButton("autofill")
      .setPosition(width-offset,init+40+40)
      .setColorValue(255)
      .setFont(createFont("Georgia",15))
      .setSize(80,30);
      ;
  // добавляем кнопку получить
  cp5.addButton("save")
    .setPosition(width-offset,init+40+40+40)
    .setColorValue(255)
    .setFont(createFont("Georgia",20))
    .setSize(80,30);
    ;

  cp5.addButton("imp")
    .setPosition(width-offset,init+40+40+40+40)
    .setColorValue(255)
    .setFont(createFont("Georgia",20))
    .setSize(80,30);
    ;
  init+=80;
  // Добавляем кнопки для изменения списка портов
  cp5.addButton("open")
    .setPosition(width-140,init)
    .setColorValue(255)
    .setFont(createFont("Georgia",20))
    .setSize(100,30);
    ;
  cp5.addButton("close")
    .setPosition(width-140,init+40)
    .setColorValue(255)
    .setFont(createFont("Georgia",20))
    .setSize(100,30);
    ;
  cp5.addButton("refresh")
    .setPosition(width-140,init+40+40)
    .setColorValue(255)
    .setFont(createFont("Georgia",20))
    .setSize(100,30);
    ;
                  
  cp5.addButton("refresh_clock_time")
    .setPosition(width-280,init+40+40+80)
    .setColorValue(255)
    .setFont(createFont("Georgia",20))
    .setSize(250,30);
    ;            
             
  cp5.addButton("set_rang_time")
    .setPosition(width-280,init+40+40+80+80)
    .setColorValue(255)
    .setFont(createFont("Georgia",20))
    .setSize(250,30);
    ;        
            
  // Добавляем спимок ком портов
  cp5.addScrollableList("comlist")
    .setPosition(width-140,10)
    .setColorValue(255)
    .setFont(createFont("Georgia",20))
    .setBarHeight(30)
    .setItemHeight(30)
    .close()
  ;

  //Поле для установления продолжительности звонков
  offset = 280;
  cp5.addTextfield("min")
     .setPosition(930,init+offset)
     .setSize(50,25)
     .setFont(font)
     .setColor(color(255))
     .setAutoClear(false)
     .setText("00");
   
  cp5.addTextfield("sec")
     .setPosition(1010,init+offset)
     .setSize(50,25)
     .setFont(font)
     .setColor(color(255))
     .setAutoClear(false)
     .setText("00");
}

int current_day = 0;

void draw() {
  //Задний фон
  background(#75AAEB);
  fill(255);
  //Автоматическое проставление двоеточий, перевод строки, проверка на ошибки
  for (int i = 0; i<7*max_day_l_count;i++){
    if (cp5.get(Textfield.class, "R"+str(i)).isActive()){
      current_day = i;
      //антиошибка, int('0') = 48, {0=48,1=49,2=50...9=58}
      if (cp5.get(Textfield.class,"R"+str(i)).getText().length()>0){
        //Переменные,в которые будет помещено вводимое польхователем время
        int get_text_i1 = int(cp5.get(Textfield.class,"R"+str(i)).getText().charAt(0));
        int get_text_i2 = 48;
        int get_text_i3 = 48;
        int get_text_i4 = 48;
        if (cp5.get(Textfield.class,"R"+str(i)).getText().length()>1) get_text_i2 = int(cp5.get(Textfield.class,"R"+str(i)).getText().charAt(1)); 
        if (cp5.get(Textfield.class,"R"+str(i)).getText().length()>3) get_text_i3 = int(cp5.get(Textfield.class,"R"+str(i)).getText().charAt(3)); 
        if (cp5.get(Textfield.class,"R"+str(i)).getText().length()>4) get_text_i4 = int(cp5.get(Textfield.class,"R"+str(i)).getText().charAt(4));
        
        if ((get_text_i1>50) | (get_text_i1<48) | (get_text_i1>58)) cp5.get(Textfield.class,"R"+str(i)).setColor(color(200, 0, 0));
        else if (((get_text_i1==50) & (get_text_i2>51)) | (get_text_i2<48) | (get_text_i2>58)) cp5.get(Textfield.class,"R"+str(i)).setColor(color(200, 0, 0));
        else if ((get_text_i3>53) | (get_text_i3<48) | (get_text_i3>58)) cp5.get(Textfield.class,"R"+str(i)).setColor(color(200, 0, 0));
        else if ((get_text_i4<48) | (get_text_i4>58)) cp5.get(Textfield.class,"R"+str(i)).setColor(color(200, 0, 0));
        else cp5.get(Textfield.class,"R"+str(i)).setColor(255);
      }
      if (cp5.get(Textfield.class,"R"+str(i)).getText().length()==2){
        if (AUTOFILLING) cp5.get(Textfield.class,"R"+str(i)).setText(cp5.get(Textfield.class,"R"+str(i)).getText()+":");
      }
    }
  }
}
public void submit() { //Отправить в МК расписание
  int counter = 0;
  int test_counter = 0;
  boolean need_write = false;
  for (int i = 1; i<=max_day_l_count;i++){  
    String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
    if (test.length() == 5){
      need_write = true;
    }
    test_counter+=1;
  }
  if (need_write){
    serial.write("M");
    for (int i = 1; i<=max_day_l_count;i++){  
      String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
      if (text.length()==5){
      serial.write(text.charAt(0));
      serial.write(text.charAt(1));
      serial.write(text.charAt(3));
      serial.write(text.charAt(4));
      }
      counter+=1;
    }
  }
  else counter += max_day_l_count;
  need_write = false;
  for (int i = 1; i<=max_day_l_count;i++){  
    String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
    if (test.length() == 5){
      need_write = true;
    }
    test_counter+=1;
  }
  if (need_write){
    serial.write("T");
    for (int i = 1; i<=max_day_l_count;i++){  
      String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
      if (text.length()==5){
      serial.write(text.charAt(0));
      serial.write(text.charAt(1));
      serial.write(text.charAt(3));
      serial.write(text.charAt(4));
      }
      counter+=1;
    }
  }
  else counter += max_day_l_count;
  need_write = false;
  for (int i = 1; i<=max_day_l_count;i++){  
    String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
    if (test.length() == 5){
      need_write = true;
    }
    test_counter+=1;
  }
  if (need_write){
    serial.write("W");
    for (int i = 1; i<=max_day_l_count;i++){  
      String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
      if (text.length()==5){
      println(text.charAt(0));
      println(text.charAt(1));
      println(text.charAt(3));
      println(text.charAt(4));
      serial.write(text.charAt(0));
      serial.write(text.charAt(1));
      serial.write(text.charAt(3));
      serial.write(text.charAt(4));
      }
      counter+=1;
    }
  }
  else counter += max_day_l_count;
  need_write = false;
  for (int i = 1; i<=max_day_l_count;i++){  
    String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
    if (test.length() == 5){
      need_write = true;
    }
    test_counter+=1;
  }
  if (need_write){
    serial.write("H");
    for (int i = 1; i<=max_day_l_count;i++){  
      String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
      if (text.length()==5){
      serial.write(text.charAt(0));
      serial.write(text.charAt(1));
      serial.write(text.charAt(3));
      serial.write(text.charAt(4));
      }
      counter+=1;
    }
  }
  else counter += max_day_l_count;
  need_write = false;
  for (int i = 1; i<=max_day_l_count;i++){  
    String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
    if (test.length() == 5){
      need_write = true;
    }
    test_counter+=1;
  }
  if (need_write){
    serial.write("F");
    for (int i = 1; i<=max_day_l_count;i++){  
      String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
      if (text.length()==5){
      serial.write(text.charAt(0));
      serial.write(text.charAt(1));
      serial.write(text.charAt(3));
      serial.write(text.charAt(4));
      }
      counter+=1;
    }
  }
  else counter += max_day_l_count;
  need_write = false;
  for (int i = 1; i<=max_day_l_count;i++){  
    String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
    if (test.length() == 5){
      need_write = true;
    }
    test_counter+=1;
  }
  if (need_write){
    serial.write("S");
    for (int i = 1; i<=max_day_l_count;i++){  
      String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
      if (text.length()==5){
      serial.write(text.charAt(0));
      serial.write(text.charAt(1));
      serial.write(text.charAt(3));
      serial.write(text.charAt(4));
      }
      counter+=1;
    }
  }
  else counter += max_day_l_count;
  need_write = false;
  for (int i = 1; i<=max_day_l_count;i++){  
    String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
    if (test.length() == 5){
      need_write = true;
    }
    test_counter+=1;
  }
  if (need_write){
    serial.write("Z");
    for (int i = 1; i<=max_day_l_count;i++){  
      String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
      if (text.length()==5){
      serial.write(text.charAt(0));
      serial.write(text.charAt(1));
      serial.write(text.charAt(3));
      serial.write(text.charAt(4));
      }
      counter+=1;
    }
  }
}
public void clear() { //Очистить ввод
  for (int i = 0; i<=7*max_day_l_count-1;i++){  
    cp5.get(Textfield.class,"R"+str(i)).clear();
  }
}
public void autofill() { //Вкл/выкл автозаполнение
  AUTOFILLING = !AUTOFILLING;
}
public void open() { //Функции кнопок для подключения
  serial = new Serial(this, portName, 9600);
}
public void close() { //Закрыть порт подключения МК к компьютеру
  serial.stop();
}
public void refresh() { //Обновить
  String list[] = Serial.list();
  cp5.get(ScrollableList.class, "comlist").clear();
  cp5.get(ScrollableList.class, "comlist").addItems(list);
}
public void comlist(int n) { //Список
  portName = Serial.list()[n];
}
public void refresh_clock_time() { //Обновляем время на часах
  String current_seconds = Integer.toString(second());
  String current_minutes = Integer.toString(minute());
  String current_hours = Integer.toString(hour());
  serial.write("N");
  serial.write(current_seconds.charAt(0));
  serial.write(current_seconds.charAt(1));
  serial.write(current_minutes.charAt(0));
  serial.write(current_minutes.charAt(1));
  serial.write(current_hours.charAt(0));
  serial.write(current_hours.charAt(1));
}
public void set_rang_time(){ //Устанавливаем продолжительность звонка
  String mins = cp5.get(Textfield.class,"min").getText();
  String secs = cp5.get(Textfield.class,"sec").getText();
  serial.write("R");
  serial.write(secs.charAt(0));
  serial.write(secs.charAt(1));
  serial.write(mins.charAt(0));
  serial.write(mins.charAt(1));
}
public void save(){ //Для импорта настроек звонков
  selectInput("Select a file to process:", "fileSelected");
  is_imp = false;
}
public void imp(){ //Импорт файла
  is_imp = true;
  selectInput("Select a file to process:", "fileSelected");
}
void fileSelected(File selection) { //Был ли выбран файл
  if (selection == null) println("Window was closed or the user hit cancel.");
  else {
    String path = selection.getAbsolutePath().replace("\\", "\\"+"\\");
    println(path);
    if (!is_imp){
      output = createWriter(path); 
      int counter = 0;
      int test_counter = 0;
      boolean need_write = false;
      for (int i = 1; i<=max_day_l_count;i++){  
        String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
        if (test.length() == 5){
          need_write = true;
        }
        test_counter+=1;
      }
      if (need_write){
        output.println("M");
        for (int i = 1; i<=max_day_l_count;i++){  
          String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
          if (text.length()==5){
          output.println(text);
          }
          counter+=1;
        }
      }
      else counter += max_day_l_count;
      need_write = false;
      for (int i = 1; i<=max_day_l_count;i++){  
        String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
        if (test.length() == 5){
          need_write = true;
        }
        test_counter+=1;
      }
      if (need_write){
        output.println("T");
        for (int i = 1; i<=max_day_l_count;i++){  
          String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
          if (text.length()==5){
          output.println(text);
          }
          counter+=1;
        }
      }
      else counter += max_day_l_count;
      need_write = false;
      for (int i = 1; i<=max_day_l_count;i++){  
        String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
        if (test.length() == 5){
          need_write = true;
        }
        test_counter+=1;
      }
      if (need_write){
        output.println("W");
        for (int i = 1; i<=max_day_l_count;i++){  
          String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
          if (text.length()==5){
          output.println(text);
          }
          counter+=1;
        }
      }
      else counter += max_day_l_count;
      need_write = false;
      for (int i = 1; i<=max_day_l_count;i++){  
        String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
        if (test.length() == 5){
          need_write = true;
        }
        test_counter+=1;
      }
      if (need_write){
        output.println("H");
        for (int i = 1; i<=max_day_l_count;i++){  
          String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
          if (text.length()==5){
          output.println(text);
          }
          counter+=1;
        }
      }
      else counter += max_day_l_count;
      need_write = false;
      for (int i = 1; i<=max_day_l_count;i++){  
        String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
        if (test.length() == 5){
          need_write = true;
        }
        test_counter+=1;
      }
      if (need_write){
        output.println("F");
        for (int i = 1; i<=max_day_l_count;i++){  
          String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
          if (text.length()==5){
          output.println(text);
          }
          counter+=1;
        }
      }
      else counter += max_day_l_count;
      need_write = false;
      for (int i = 1; i<=max_day_l_count;i++){  
        String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
        if (test.length() == 5){
          need_write = true;
        }
        test_counter+=1;
      }
      if (need_write){
        output.println("S");
        for (int i = 1; i<=max_day_l_count;i++){  
          String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
          if (text.length()==5){
          output.println(text);
          }
          counter+=1;
        }
      }
      else counter += max_day_l_count;
      need_write = false;
      for (int i = 1; i<=max_day_l_count;i++){  
        String test = cp5.get(Textfield.class,"R"+str(test_counter)).getText();
        if (test.length() == 5){
          need_write = true;
        }
        test_counter+=1;
      }
      if (need_write){
        output.println("Z");
        for (int i = 1; i<=max_day_l_count;i++){  
          String text = cp5.get(Textfield.class,"R"+str(counter)).getText();
          if (text.length()==5){
          output.println(text);
          }
          counter+=1;
        }
      }
      output.flush();
      output.close(); 
    }  
    else {
      String[] lines = loadStrings(path);
      int counter = 0;
      for (int i = 0 ; i < lines.length; i++) {
        if (lines[i].equals("M") == true) counter = 0*max_day_l_count-1;
        else if (lines[i].equals("T") == true) counter = 1*max_day_l_count-1;
        else if (lines[i].equals("W") == true) counter = 2*max_day_l_count-1;
        else if (lines[i].equals("H") == true) counter = 3*max_day_l_count-1;
        else if (lines[i].equals("F") == true) counter = 4*max_day_l_count-1;
        else if (lines[i].equals("S") == true) counter = 5*max_day_l_count-1;
        if (!(lines[i].equals("M")||lines[i].equals("T")||lines[i].equals("W")||lines[i].equals("H")
        ||lines[i].equals("F")||lines[i].equals("S"))) cp5.get(Textfield.class,"R"+str(counter)).setText(lines[i]);
        counter+=1;
      }
    }
  }
}
void keyReleased() { //Был ли нажат TAB или ENTER, в этом случае переводим строку
    if ((keyCode == TAB) | (keyCode == ENTER) | 
    (cp5.get(Textfield.class,"R"+str(current_day)).getText().length()>4)){
      cp5.get(Textfield.class, "R"+str(current_day)).setFocus(false);
      if (current_day==7*max_day_l_count-1) current_day = -1;
      cp5.get(Textfield.class, "R"+str(current_day+1)).setFocus(true);
    } 
}
