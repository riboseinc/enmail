# (c) Copyright 2018 Ribose Inc.
#

# The smallest possible JPEG.
# From: https://github.com/mathiasbynens/small
SMALLEST_JPEG = (
  "\xFF\xD8\xFF\xDB\x00C\x00\x03\x02\x02\x02\x02\x02\x03\x02\x02\x02\x03\x03" +
  "\x03\x03\x04\x06\x04\x04\x04\x04\x04\b\x06\x06\x05\x06\t\b\n\n\t\b\t\t\n\f" +
  "\x0F\f\n\v\x0E\v\t\t\r\x11\r\x0E\x0F\x10\x10\x11\x10\n\f\x12\x13\x12\x10" +
  "\x13\x0F\x10\x10\x10\xFF\xC9\x00\v\b\x00\x01\x00\x01\x01\x01\x11\x00\xFF" +
  "\xCC\x00\x06\x00\x10\x10\x05\xFF\xDA\x00\b\x01\x01\x00\x00?\x00\xD2\xCF " +
  "\xFF\xD9"
).force_encoding("ASCII-8BIT").freeze
