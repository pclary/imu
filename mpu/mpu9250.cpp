#include "mpu9250.h"
#include <Arduino.h>
#include <SPI.h>
#include <cstddef>
#include <cstdio>
#include "mpu9250_defs.h"


SPISettings spi_slow(1000000, MSBFIRST, SPI_MODE0);
SPISettings spi_fast(1000000, MSBFIRST, SPI_MODE0);


inline void reg_write(int ncs_pin, uint8_t reg_addr, uint8_t* data, size_t count)
{
    SPI.beginTransaction(spi_slow);
    digitalWrite(ncs_pin, LOW);
    SPI.transfer(reg_addr);
    for (size_t i = 0; i < count; ++i)
        SPI.transfer(data[i]);
    digitalWrite(ncs_pin, HIGH);
    SPI.endTransaction();
}


inline void reg_read(int ncs_pin, uint8_t reg_addr, uint8_t* data, size_t count)
{
    SPI.beginTransaction(spi_slow);
    digitalWrite(ncs_pin, LOW);
    SPI.transfer(reg_addr | 0x80);
    for (size_t i = 0; i < count; ++i)
        data[i] = SPI.transfer(0);
    digitalWrite(ncs_pin, HIGH);
    SPI.endTransaction();
}


inline void reg_write_single(int ncs_pin, uint8_t reg_addr, uint8_t value)
{
    SPI.beginTransaction(spi_slow);
    digitalWrite(ncs_pin, LOW);
    SPI.transfer(reg_addr);
    SPI.transfer(value);
    digitalWrite(ncs_pin, HIGH);
    SPI.endTransaction();
}


inline uint8_t reg_read_single(int ncs_pin, uint8_t reg_addr)
{
    SPI.beginTransaction(spi_slow);
    digitalWrite(ncs_pin, LOW);
    SPI.transfer(reg_addr | 0x80);
    uint8_t value = SPI.transfer(0);
    digitalWrite(ncs_pin, HIGH);
    SPI.endTransaction();
    return value;
}


bool mpu_init(int ncs_pin)
{
    pinMode(ncs_pin, OUTPUT);
    digitalWrite(ncs_pin, HIGH);
    SPI.begin();

    if (uint8_t whoami = reg_read_single(ncs_pin, WHO_AM_I) != 0x71)
    {
        char buf[64];
        snprintf(buf, sizeof buf, "Expected 0x71, got 0x%02x\n", whoami);
        Serial.print(buf);
        return false;
    }

    return true;
}


sensor_data mpu_get_data(int ncs_pin)
{
    sensor_data sensors;

    return sensors;
}
