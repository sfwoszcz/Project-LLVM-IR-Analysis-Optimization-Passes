// SPDX-License-Identifier: MIT

#include <stdint.h>

uint32_t scale_by_eight(uint32_t value) { return value * UINT32_C(8); }

uint32_t scale_by_three(uint32_t value) { return value * UINT32_C(3); }

uint32_t sum_scaled(const uint32_t* values, uint32_t count) {
  uint32_t sum = 0;

  for (uint32_t index = 0; index < count; ++index)
    sum += values[index] * UINT32_C(8);

  return sum;
}
