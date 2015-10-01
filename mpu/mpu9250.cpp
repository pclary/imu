#include "mpu9250.h"
#include <Arduino.h>
#include <SPI.h>
#include <cstddef>
#include <cstdio>
#include "mpu9250_defs.h"


SPISettings spi_slow(1000000, MSBFIRST, SPI_MODE0);
SPISettings spi_fast(8000000, MSBFIRST, SPI_MODE0);


inline void reg_write(int ncs_pin, uint8_t reg_addr, uint8_t value)
{
    digitalWrite(ncs_pin, LOW);
    SPI.transfer(reg_addr);
    SPI.transfer(value);
    digitalWrite(ncs_pin, HIGH);
}


inline uint8_t reg_read(int ncs_pin, uint8_t reg_addr)
{
    digitalWrite(ncs_pin, LOW);
    SPI.transfer(reg_addr | 0x80);
    uint8_t value = SPI.transfer(0);
    digitalWrite(ncs_pin, HIGH);
    return value;
}


inline void reg_write_multi(int ncs_pin, uint8_t reg_addr, uint8_t* data, size_t count)
{
    digitalWrite(ncs_pin, LOW);
    SPI.transfer(reg_addr);
    for (size_t i = 0; i < count; ++i)
        SPI.transfer(data[i]);
    digitalWrite(ncs_pin, HIGH);
}


inline void reg_read_multi(int ncs_pin, uint8_t reg_addr, uint8_t* data, size_t count)
{
    digitalWrite(ncs_pin, LOW);
    SPI.transfer(reg_addr | 0x80);
    for (size_t i = 0; i < count; ++i)
        data[i] = SPI.transfer(0);
    digitalWrite(ncs_pin, HIGH);
}


bool mpu_init(int ncs_pin)
{
    pinMode(ncs_pin, OUTPUT);
    digitalWrite(ncs_pin, HIGH);
    SPI.begin();

    SPI.beginTransaction(spi_slow);

    uint8_t whoami = reg_read(ncs_pin, WHO_AM_I);
    if (whoami != 0x71)
    {
        char buf[64];
        snprintf(buf, sizeof buf, "Expected 0x71, got 0x%02x\n", whoami);
        Serial.print(buf);
        return false;
    }

    // Reset device
    reg_write(ncs_pin, PWR_MGMT_1,     0x80);
    delayMicroseconds(1000);

    // Set up device registers
    reg_write(ncs_pin, USER_CTRL,                    0x70);
    reg_write(ncs_pin, PWR_MGMT_1,                   0x01);
    reg_write(ncs_pin, PWR_MGMT_2,                   0x00);
    reg_write(ncs_pin, SMPLRT_DIV,                   0x00);
    reg_write(ncs_pin, CONFIG,                       0x00);
    reg_write(ncs_pin, GYRO_CONFIG,                  0x10);
    reg_write(ncs_pin, ACCEL_CONFIG,                 0x08);
    reg_write(ncs_pin, ACCEL_CONFIG_2,               0x00);
    // reg_write(ncs_pin, INT_PIN_CFG,                  0x30);
    // reg_write(ncs_pin, INT_ENABLE,                   0x00);
    reg_write(ncs_pin, INT_PIN_CFG,                  0x10);
    reg_write(ncs_pin, INT_ENABLE,                   0x01);
    reg_write(ncs_pin, I2C_MST_CTRL,                 0x0d);
    // reg_write(ncs_pin, FIFO_EN,                      0xf8);
    reg_write(ncs_pin, FIFO_EN,                      0x78);

    // Set up magnetometer
    // reg_write(ncs_pin, I2C_SLV0_ADDR,                AK8963_ADDR);
    // reg_write(ncs_pin, I2C_SLV0_REG,                 CNTL2);
    // reg_write(ncs_pin, I2C_SLV0_D0,                  0x01);
    // reg_write(ncs_pin, I2C_SLV0_CTRL,                0xa1);
    // delayMicroseconds(100);
    // reg_write(ncs_pin, I2C_SLV0_REG,                 CNTL1);
    // reg_write(ncs_pin, I2C_SLV0_D0,                  0x16);
    // reg_write(ncs_pin, I2C_SLV0_CTRL,                0xa1);
    // delayMicroseconds(100);
    // reg_write(ncs_pin, I2C_SLV4_CTRL,                0x0f);
    // reg_write(ncs_pin, I2C_MST_DELAY_CTRL,           0x01);
    // reg_write(ncs_pin, I2C_SLV0_CTRL,                0x00);
    // reg_write(ncs_pin, I2C_SLV0_ADDR,                AK8963_ADDR | 0x80);
    // reg_write(ncs_pin, I2C_SLV0_REG,                 HXL);
    // reg_write(ncs_pin, I2C_SLV0_CTRL,                0xd6);

    SPI.endTransaction();

    return true;
}


size_t mpu_get_data(int ncs_pin, sensor_data* sensors)
{
    const size_t bytes_per_set = 2*(3 + 3);
    
    SPI.beginTransaction(spi_fast);
    
    uint8_t fifo_count_raw[2];
    reg_read_multi(ncs_pin, FIFO_COUNTH, fifo_count_raw, 2);
    size_t fifo_count = (fifo_count_raw[0] & 0xf) << 8 | fifo_count_raw[1];
    size_t set_count = fifo_count / bytes_per_set;

    uint8_t set_buffer[bytes_per_set];
    for (size_t i = 0; i < set_count; ++i)
    {
        reg_read_multi(ncs_pin, FIFO_R_W, set_buffer, bytes_per_set);
        for (size_t j = 0; j < 3; ++j)
            sensors[i].accel[j] = set_buffer[2*j+0] << 8 | set_buffer[2*j+1];
        for (size_t j = 0; j < 3; ++j)
            sensors[i].gyro[j]  = set_buffer[2*j+6] << 8 | set_buffer[2*j+7];
    }

    SPI.endTransaction();
    
    return set_count;
}
