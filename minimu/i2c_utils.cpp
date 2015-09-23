#include "i2c_utils.h"
#include <i2c_t3.h>


uint8_t get_register(uint8_t dev_addr, uint8_t reg_addr)
{
    Wire.beginTransmission(dev_addr);
    Wire.write(reg_addr);
    Wire.endTransmission(I2C_NOSTOP);
    Wire.requestFrom(dev_addr, size_t(1));
    Wire.finish();
    return Wire.readByte();
}


void get_registers(uint8_t dev_addr, uint8_t reg_addr, uint8_t* output_buffer, size_t count)
{
    Wire.beginTransmission(dev_addr);
    Wire.write(reg_addr);
    Wire.endTransmission(I2C_NOSTOP);
    Wire.requestFrom(dev_addr, count);
    Wire.finish();
    for (unsigned i = 0; i < count; ++i)
        output_buffer[i] = Wire.readByte();
}


void set_register(uint8_t dev_addr, uint8_t reg_addr, uint8_t reg_value)
{
    Wire.beginTransmission(dev_addr);
    Wire.write(reg_addr);
    Wire.write(reg_value);
    Wire.endTransmission();
}
