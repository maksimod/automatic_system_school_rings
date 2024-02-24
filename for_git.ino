//загрузка библиотек
//вспомогательные
#include <EEPROM.h>
#include <Wire.h> 
//для дисплея
#include <LiquidCrystal_I2C.h>
LiquidCrystal_I2C lcd(0x27,16,2);
//для часов реального времени
#include <SPI.h>
#include <microDS3231.h>
MicroDS3231 rtc;
//инициализация перменных
int read_counter = 0;
int write_counter = 0;

byte real_hours = 0;
byte real_minutes = 0;
byte now_day = 0;
byte real_seconds = 0;

char real_day;

boolean was_ring = true;
int was_minute;

unsigned long real_time;

unsigned long display_update_time;

unsigned long ring_time = 9000;

boolean alarm = false;

//есть реле с инвертированным управлением. Применяется в нашей схеме
boolean high = 0;
boolean low = 1;

//Для записи поступивших в буфер данных
String all_pos = "";
int all_pos_counter = 0;

void setup() {
  // настраиваем порты
  //звонок
  pinMode(6, OUTPUT);
  digitalWrite(6,low);

  //Дисплей
  lcd.init();
  lcd.backlight();
}

unsigned long alarm_time;

boolean was_turned = true;


//Позвонить
void set_ring(){
  was_ring = false;
  was_minute = real_minutes;
  real_time = millis();
  //включаем звонок
  digitalWrite(6,high);
}

//Делает три длинныхз звонка
void alarm_ring(){
  if (millis() - alarm_time > ring_time*2l+ring_time/2l+ring_time*2l+ring_time/2l+ring_time*2l+ring_time/2l){
    alarm = false;
  }
  else if (millis() - alarm_time > ring_time*2l+ring_time/2l+ring_time*2l+ring_time/2l+ring_time*2l){
    digitalWrite(6,low);
  }
  else if (millis() - alarm_time > ring_time*2l+ring_time/2l+ring_time*2l+ring_time/2l){
    digitalWrite(6,high);
  }
  else if (millis() - alarm_time > ring_time*2l+ring_time/2l+ring_time*2l){
    digitalWrite(6,low);
  }
  else if (millis() - alarm_time > ring_time*2l+ring_time/2l){
    digitalWrite(6,high);
  }
  else if (millis() - alarm_time > ring_time*2l){
    digitalWrite(6,low);
  }
}

void loop() {
  // Получение текущего времени, его запись в переменные
  DateTime now = rtc.getTime();
  
  real_hours = now.hour;
  real_minutes = now.minute;
  real_seconds = now.second;
  now_day = now.day;

  //Изменяем формат переменной на нужный
  if (now_day == 1) real_day = 'M';
  else if (now_day == 2) real_day = 'T';
  else if (now_day == 3) real_day = 'W';
  else if (now_day == 4) real_day = 'H';
  else if (now_day == 5) real_day = 'F';
  else if (now_day == 6) real_day = 'S';
  else if (now_day == 7) real_day = 'Z';

  // Если тревога, вызываем специальную функцию
  if (alarm) alarm_ring();
  else {
    if (digitalRead(2)){
      if (was_turned) {
      alarm = true;
      digitalWrite(6,high);
      was_turned = false;
      alarm_time = millis();
      }
    }
    else was_turned = true;
  }

  // Проверяем, надо ли звонить
  if (was_ring){
    read_counter = 0;
    while (EEPROM[read_counter]){
      // Читаем данные из EEPROM
      char data = char(EEPROM[read_counter]);
      read_counter++;
      //Проверяем на соответствие нужному дню
      if (data == 'R'){
        String ring_long;
        while (data){
          data = char(EEPROM[read_counter]);
          read_counter++;
          ring_long += String(data);
        }
        long real_secs = 0;
        real_secs += long(ring_long[0]-'0')*10;
        real_secs += long(ring_long[1]-'0');
        real_secs += long(ring_long[2]-'0')*10*60;
        real_secs += long(ring_long[3]-'0')*60;
        real_secs *= 1000;
        ring_time = real_secs;
      }
      //Если текущий день недели равен дню недели в данных
      if (data==real_day){
        data = char(EEPROM[read_counter]);
        read_counter++;
        // Считываем время пока не наткнулись на следующий день недели в расписании
        while ((data == '0') or (data == '1') 
        or (data == '2') or (data == '3') or (data == '4') 
        or (data == '5') or (data == '6') or (data == '7') 
        or (data == '8') or (data == '9')){
          // Читаем часы
          String current_hour;
          
          if (data=='0') {
            data = char(EEPROM[read_counter]);
            read_counter++;
            current_hour = String(data);
          }
          else {
            current_hour = String(data);
            data = char(EEPROM[read_counter]);
            read_counter++;
            current_hour += String(data);
          }
  
          data = char(EEPROM[read_counter]);
          read_counter++;
          
          // Читаем минуты
          String current_minute;

          if (data=='0') {
            data = char(EEPROM[read_counter]);
            read_counter++;
            current_minute = String(data);
          }
          else {
            current_minute = String(data);
            data = char(EEPROM[read_counter]);
            read_counter++;
            current_minute += String(data);
          }
  
          data = char(EEPROM[read_counter]);
          read_counter++;
          
          //Проверяем данные
          if ((real_hours == current_hour.toInt()) and (real_minutes == current_minute.toInt())){
            set_ring();
          }
        }
        read_counter--;
      }
    }
  }
  else{
    //Проверяем, нужно ли прекратить звонить. Если нужно, прекращаем
    if (millis()-real_time>=ring_time){
      digitalWrite(6,low);
    }
    if (was_minute != real_minutes){
      was_ring = true;
    }
  }
  // Читаем данные о новом расписании, которое отправила программа
  if (Serial.available()>0){
    write_counter = 0;
    all_pos_counter = 0;
    all_pos = Serial.readString();
    all_pos_counter++;
    char data = char(EEPROM[0]);
    byte key = all_pos[0];
    Serial.println(char(key));
    //Если нужно синхронизировать
    if (char(key) == 'N'){
      String s = String(char(all_pos[all_pos_counter]));
      all_pos_counter++;
      s += String(char(all_pos[all_pos_counter]));
      all_pos_counter++;
      String m = String(char(all_pos[all_pos_counter]));
      all_pos_counter++;
      m += String(char(all_pos[all_pos_counter]));
      all_pos_counter++;
      String h = String(char(all_pos[all_pos_counter]));
      all_pos_counter++;
      h += String(char(all_pos[all_pos_counter]));
      all_pos_counter++;
      int seconds = s.toInt();
      int minutes = m.toInt();
      int hours = h.toInt();
      now.second = seconds;
      now.minute = minutes;
      now.hour = hours;
      // отправляем в rtc
      rtc.setTime(now);
    }
    //Если нужно изменить длительность звонков
    else if (char(key) == 'R'){
      char s1 = char(all_pos[all_pos_counter]);
      all_pos_counter++;
      char s2 = char(all_pos[all_pos_counter]);
      all_pos_counter++;
      char m1 = char(all_pos[all_pos_counter]);
      all_pos_counter++;
      char m2 = char(all_pos[all_pos_counter]);
      all_pos_counter++;
      write_counter = 0;
      char data = char(EEPROM[write_counter]);
      while (data){
        write_counter+=1;
        data = char(EEPROM[write_counter]);
      }
      EEPROM.update(write_counter, byte('R'));
      write_counter++;
      EEPROM.update(write_counter, byte(s1));
      write_counter++;
      EEPROM.update(write_counter, byte(s2));
      write_counter++;
      EEPROM.update(write_counter, byte(m1));
      write_counter++;
      EEPROM.update(write_counter, byte(m2));
    }
    //Если нужно изменить расписание
    else{
      // Очищаем EEPROM память от прошшлого расписания
      write_counter = 0;
      while (data){
        EEPROM.write(write_counter, 0);
        write_counter+=1;
        data = char(EEPROM[write_counter]);
      }
      EEPROM.write(write_counter, 0);
      write_counter = 0;
      all_pos_counter = 0;
      char das;
      while (all_pos.length()>all_pos_counter){
        das = char(all_pos[all_pos_counter]);
        all_pos_counter++;

        EEPROM.update(write_counter, byte(das));
        write_counter++;
      }
    }
  } 
  // обновлять дисплей 10 раз в секунду
  if (millis() - display_update_time > 100){
    lcd.setCursor(0,0);
    lcd.print("GBOU SOSH №43");
    lcd.setCursor(0,1);
    lcd.print("now:");
    if (real_day == 'M'){
      lcd.print("mon");
    }
    else if (real_day == 'T'){
      lcd.print("tue");
    }
    else if (real_day == 'W'){
      lcd.print("wed");
    }
    else if (real_day == 'H'){
      lcd.print("thu");
    }
    else if (real_day == 'F'){
      lcd.print("fri");
    }
    else if (real_day == 'S'){
      lcd.print("sat");
    }
    else lcd.print("sun");
    
    lcd.print(",");
    
    if (real_hours<10){
      if (real_hours == 0){
        lcd.print(0);
        lcd.print(0);  
      }
      else{
        lcd.print(0);
        lcd.print(real_hours);
      }
    }
    else lcd.print(real_hours);
    lcd.print(":");
    if (real_minutes<10){
      if (real_minutes == 0){
        lcd.print(0);
        lcd.print(0);  
      }
      else{
        lcd.print(0);
        lcd.print(real_minutes);
      }
    }
    else lcd.print(real_minutes);
    lcd.print(":");
    if (real_seconds<10){
      if (real_seconds == 0){
        lcd.print(0);
        lcd.print(0);  
      }
      else{
        lcd.print(0);
        lcd.print(real_seconds);
      }
    }
    else lcd.print(real_seconds);
    
    display_update_time = millis();
  }
}
