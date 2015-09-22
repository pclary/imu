#ifndef I2C_UTILS_H
#define I2C_UTILS_H

#include <cstdint>
#include <cstddef>


uint8_t get_register(uint8_t dev_addr, uint8_t reg_addr);
void get_registers(uint8_t dev_addr, uint8_t reg_addr, uint8_t* output_buffer, size_t count);
void set_register(uint8_t dev_addr, uint8_t reg_addr, uint8_t reg_value);


#endif // I2C_UTILS_H
