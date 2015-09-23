#include <Arduino.h>
#include <i2c_t3.h>
#include <cstdint>
#include <cstdio>
#include "l3gd20.h"
#include "lsm303dlhc.h"


void setup()
{
    Serial.begin(115200);
    Wire.begin(I2C_MASTER, 0, I2C_PINS_18_19, I2C_PULLUP_EXT, I2C_RATE_100);
    pinMode(13, OUTPUT);
    
    digitalWrite(13, HIGH);
    delay(100);
    digitalWrite(13, LOW);
    
    delay(1000);

    Serial.print("Initializing...");
    
    if (!gyro_init())
        Serial.write("[init_gyro failed]");
    if (!accel_init())
        Serial.write("[init_accel failed]");
    if (!mag_init())
        Serial.write("[init_mag failed]");

    delay(250);

    Serial.print("done!\n");
}


std::array<int16_t, 3> gyro_data;
std::array<int16_t, 3> accel_data;
std::array<int16_t, 3> mag_data;


void loop()
{
    if (accel_data_ready())
        accel_data = get_accel_data();
    if (mag_data_ready())
        mag_data = get_mag_data();

    while (!gyro_data_ready());
    gyro_data = get_gyro_data();

    char buf[64];
    snprintf(buf, sizeof(buf), "%d, %d, %d, %d, %d, %d, %d, %d, %d\n",
             gyro_data[0], gyro_data[1], gyro_data[2],
             accel_data[0], accel_data[1], accel_data[2],
             mag_data[0], mag_data[1], mag_data[2]);
    Serial.write(buf);
}
