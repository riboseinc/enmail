# (c) Copyright 2018 Ribose Inc.
#

# The smallest possible JPEG.
# From: https://github.com/mathiasbynens/small
SMALLEST_JPEG = (
  "\xFF\xD8\xFF\xDB\u0000C\u0000\u0003\u0002\u0002\u0002\u0002\u0002\u0003"
  "\u0002\u0002\u0002\u0003\u0003\u0003\u0003\u0004\u0006\u0004\u0004\u0004"
  "\u0004\u0004\b\u0006\u0006\u0005\u0006\t\b\n\n\t\b\t\t\n\f\u000F\f\n\v\u000E"
  "\v\t\t\r\u0011\r\u000E\u000F\u0010\u0010\u0011\u0010\n\f\u0012\u0013\u0012"
  "\u0010\u0013\u000F\u0010\u0010\u0010\xFF\xC9\u0000\v\b\u0000\u0001\u0000"
  "\u0001\u0001\u0001\u0011\u0000\xFF\xCC\u0000\u0006\u0000\u0010\u0010\u0005"
  "\xFF\xDA\u0000\b\u0001\u0001\u0000\u0000?\u0000\xD2\xCF \xFF\xD9"
).force_encoding("ASCII-8BIT").freeze
