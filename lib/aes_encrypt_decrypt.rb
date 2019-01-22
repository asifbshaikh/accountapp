require 'openssl'
require 'base64'
require 'json'

class AesEncryptDecrypt


  #KEY = "bztX7+eOntiNGUYUHOQ4+0g4CXnBNFDCwN4N5oMB4PKQ3WbNGTzS7xt7HX7h92LC"
  ALGORITHM = 'AES-256-ECB'
  #ALGORITHM = 'aes-256-ecb'
  
  #key is EK
  def encrypt(msg, key)
    Rails.logger.debug "AesEncryptDecrypt::encrypt::BEGIN"
    begin
      cipher = OpenSSL::Cipher.new(ALGORITHM)
      cipher.encrypt()
      cipher.padding = 1
      cipher.key = key
      crypt = cipher.update(msg) + cipher.final
      return (Base64.encode64(crypt))
    rescue Exception => exc
      Rails.logger.error ("Error when encrypting message #{msg} is #{exc.message}")
      raise exc
    end
  end

  def decrypt(msg, key)
    Rails.logger.debug "AesEncryptDecrypt::decrypt::BEGIN"
    begin
      cipher = OpenSSL::Cipher.new(ALGORITHM)
      cipher.decrypt()
      cipher.padding = 1
      cipher.key = key
      tempkey = Base64.decode64(msg)
      crypt = cipher.update(tempkey)
      crypt << cipher.final()
      return crypt
    rescue Exception => exc
      Rails.logger.error ("Error when decrypting #{msg} is #{exc}")
      raise exc
    end
  end
end
##{"status_cd":"1","auth_token":"0c6e07b2941b4661a68e051b4d87927e","expiry":120,"sek":"bztX7+eOntiNGUYUHOQ4+0g4CXnBNFDCwN4N5oMB4PKQ3WbNGTzS7xt7HX7h92LC"}


# data= {
#   "gstin"=>"27AHQPA7599L1ZJ",
#   "fp"=>"122016",
#   "gt"=>3782969.01,
#   "cur_gt"=>3782969.01,
#   "b2b"=>[
#     {
#       "ctin"=>"01AABCE2207R1Z5",
#       "inv"=>[
#         {
#           "inum"=>"S008400",
#           "idt"=>"24-11-2016",
#           "val"=>729248.16,
#           "pos"=>"06",
#           "rchrg"=>"N",
#           "etin"=>"01AABCE5507R1C4",
#           "inv_typ"=>"R",
#           "itms"=>[
#             {
#               "num"=>1,
#               "itm_det"=>{
#                 "rt"=>5,
#                 "txval"=>10000,
#                 "iamt"=>833.33,
#                 "csamt"=>500
#               }
#             }
#           ]
#         }
#       ]
#     }
#   ],
#   "b2cl"=>[
#     {
#       "pos"=>"05",
#       "inv"=>[
#         {
#           "inum"=>"92661",
#           "idt"=>"10-01-2016",
#           "val"=>784586.33,
#           "etin"=>"27AHQPA8875L1CU",
#           "itms"=>[
#             {
#               "num"=>1,
#               "itm_det"=>{
#                 "rt"=>5,
#                 "txval"=>10000,
#                 "iamt"=>833.33,
#                 "csamt"=>500
#               }
#             }
#           ]
#         }
#       ]
#     }
#   ],
#   "cdnr"=>[
#     {
#       "ctin"=>"01AAAAP1208Q1ZS",
#       "nt"=>[
#         {
#           "ntty"=>"C",
#           "nt_num"=>"533515",
#           "nt_dt"=>"23-09-2016",
#           "p_gst"=>"N",
#           "rsn"=>"Post Sale Discount",
#           "inum"=>"915914",
#           "idt"=>"23-09-2016",
#           "val"=>123123,
#           "itms"=>[
#             {
#               "num"=>1,
#               "itm_det"=>{
#                 "rt"=>10,
#                 "txval"=>5225.28,
#                 "iamt"=>845.22,
#                 "csamt"=>789.52
#               }
#             }
#           ]
#         }
#       ]
#     }
#   ],
#   "b2cs"=>[
#     {
#       "sply_ty"=>"INTER",
#       "rt"=>5,
#       "typ"=>"E",
#       "etin"=>"01AABCE5507R1C4",
#       "pos"=>"05",
#       "txval"=>110,
#       "iamt"=>10,
#       "csamt"=>10
#     },
#     {
#       "rt"=>5,
#       "sply_ty"=>"INTER",
#       "typ"=>"OE",
#       "txval"=>100,
#       "iamt"=>10,
#       "csamt"=>10
#     }
#   ],
#   "exp"=>[
#     {
#       "exp_typ"=>"WPAY",
#       "inv"=>[
#         {
#           "inum"=>"81542",
#           "idt"=>"12-02-2016",
#           "val"=>995048.36,
#           "sbpcode"=>"ASB991",
#           "sbnum"=>7896542,
#           "sbdt"=>"04-10-2016",
#           "itms"=>[
#             {
#               "txval"=>10000,
#               "rt"=>5,
#               "iamt"=>833.33
#             }
#           ]
#         }
#       ]
#     },
#     {
#       "exp_typ"=>"WOPAY",
#       "inv"=>[
#         {
#           "inum"=>"81542",
#           "idt"=>"12-02-2016",
#           "val"=>995048.36,
#           "sbpcode"=>"ASB981",
#           "sbnum"=>7896542,
#           "sbdt"=>"04-10-2016",
#           "itms"=>[
#             {
#               "txval"=>10000,
#               "rt"=>0,
#               "iamt"=>0
#             }
#           ]
#         }
#       ]
#     }
#   ],
#   "hsn"=>{
#     "data"=>[
#       {
#         "num"=>1,
#         "hsn_sc"=>"1009",
#         "desc"=>"Goods Description",
#         "uqc"=>"kg",
#         "qty"=>2.05,
#         "val"=>995048.36,
#         "txval"=>10.23,
#         "iamt"=>14.52,
#         "csamt"=>500
#       }
#     ]
#   },
#   "nil"=>{
#     "inv"=>[
#       {
#         "sply_ty"=>"INTRB2B",
#         "expt_amt"=>123.45,
#         "nil_amt"=>1470.85,
#         "ngsup_amt"=>1258.5
#       },
#       {
#         "sply_ty"=>"INTRB2C",
#         "expt_amt"=>123.45,
#         "nil_amt"=>1470.85,
#         "ngsup_amt"=>1258.5
#       }
#     ]
#   },
#   "txpd"=>[
#     {
#       "pos"=>"05",
#       "sply_ty"=>"INTER",
#       "itms"=>[
#         {
#           "rt"=>5,
#           "ad_amt"=>100,
#           "iamt"=>9400,
#           "csamt"=>500
#         }
#       ]
#     }
#   ],
#   "at"=>[
#     {
#       "pos"=>"05",
#       "sply_ty"=>"INTER",
#       "itms"=>[
#         {
#           "rt"=>5,
#           "ad_amt"=>100,
#           "iamt"=>9400,
#           "csamt"=>500
#         }
#       ]
#     }
#   ],
#   "doc_issue"=>{
#     "doc_det"=>[
#       {
#         "doc_num"=>1,
#         "docs"=>[
#           {
#             "num"=>1,
#             "from"=>"20",
#             "to"=>"29",
#             "totnum"=>20,
#             "cancel"=>3,
#             "net_issue"=>17
#           }
#         ]
#       }
#     ]
#   },
#   "cdnur"=>[
#     {
#       "typ"=>"B2CL",
#       "ntty"=>"C",
#       "nt_num"=>"533515",
#       "nt_dt"=>"23-09-2016",
#       "p_gst"=>"N",
#       "rsn"=>"Post Sale Discount",
#       "inum"=>"915914",
#       "idt"=>"23-09-2016",
#       "val"=>64646,
#       "itms"=>[
#         {
#           "num"=>1,
#           "itm_det"=>{
#             "rt"=>10,
#             "txval"=>5225.28,
#             "iamt"=>845.22,
#             "csamt"=>789.52
#           }
#         }
#       ]
#     }
#   ]
# }

# puts data.to_json

# f= AesEncryptDecrypt.encryption(data.to_json)
# puts f
# j=AesEncryptDecrypt.decryption('Yn/b/zkogU39YGlFO2XbV43PdmSRjraeMWngXQZtW2H5oIuUwHH5AhUSns5L
# +6YcYlkksdvVqnpwM5WADuC/qZ0Yc6qGwqD9jEjhiaR6LbBjVzjnhtcOs7Dh
# ZiIBaL6Gq6wuZFMKfJo0vWyHJ9Rcz2j6lmw7j+ZeVcQ2b4yoB2WztepZoJcA
# 3U983RSBiLULNpCmMDsxCkNhmMEq8KbuRwn0aZTMPD/3qj0AQ+Adg7TGbnpR
# wdMaNNJTI0z/3I79yTs2b9QBvwVvS7jAxk9eYE0B06xBWauOFQAtuV6xY1Hu
# JzD/r89YFtU9/NyP1oIzjqiC/40Gvdw5UMLUOEoogtDGlLMd9jEG2vO9z9L1
# SS0SL1oUhA5OzC2kVKWsmFnhCQalS5uOqsQcEIJKl4iH/LhURFHsEAV6+fyC
# GZkPFZTqnyO05xqjlFyOLPBO+NHErIX9HAL6dgGuoFlgLtruAFvOMW2QsxLU
# UQOxfvVEk3h93Jtw6RUkSM1FZa4fVFFXiCTSAZQNvt1xDQnu+APKssI6yR9r
# bEbGbCMSAxLc09Gyfy7mSIG0X1zRGKeljJDNnO2k3SPXYrAet6GeCaC7l426
# V2OcQFFd+hN6dVON2pGka3tbJyKbgH9m8XqnA+jBfWl3KyVWBGYpkmbL3t33
# Ty6Fi9g1GmPNRQ3oVVnyq3g5SazUg6/tg0Y8gg/OZdwCPSdlpgWmLH/vbBCJ
# EQcPUQkPkh1iJNjrOjFjw4jBO4a0GjGiO31C0Lpeh+IYCuXCe9qF5fIQ0Tji
# mr8q7qnXz6EKeV7PzbMcUT8lysJYs0nLSYzxle0Bu92JknBVQ9oGsEaf0t8g
# MtFSoi/8gKIEnWxJmtkYsyt5gFJwAcgdWKrM1noq+q+iK5FhZVY4yCPSe4cG
# uYiIxdObA45UvRxpSMiS83dRkSv0pjqNm0oqqzWuPnN+PFPt+kC05RxDoIVR
# w/sNiHIqfdDrmFvos91MHByT7paeaHgWoWfy3rjIfr0ScqGhg5p057L1VLYh
# XJDUV07lbQh+m+g6SV50MlfF8o3U994EHiO5wZStUk98T3AIOw+5XnPjFJD6
# 5bkHIwKwjEMjT+4mTfwnJboCpDpCbSJXLDq7uRypyhMBojJvGIWxwXjVBm4R
# 4ps3+aHHpurXTn9D7r4qSl5trloXZSAuFxVCHwEy+XAIOFB+OrHseL46a/+8
# m2jWmDTBHdegIZhDZTMPKbpxD9sXJ5hiAyNb0L0WnG9h2bjaQTneqyS0A3nn
# hrQ2hSG014pXqGePDOxclDqWa5gqepHiQY7/hYjHjJgtdHfRucnDa7XS59bm
# +eFeu314JXo6oHlDagMJmp7C0/7+bRxxN80Cw6GXqtnsW6yvohODB0fVRim2
# ZJHwv4W2IDrGib1y6LJa2dJh3kXyeD0a3mI+l83y4K2YDaAuqBQW7etEbkUv
# YPmLx4TYGm8CB6OfjjU3FP/q34n9VVNMGMcN1oD7iOj1fm5mj1zO2QKgVV5J
# WAa0TWYTQ3f7EWeamxcErSOs47kVtbBCQ3yvVazmvn43yJMiwKWJONyS7ds9
# mmWIw1D0P8bwuu9lrcLFLnRPn/f8zOLf8LfPcQPogOK9cSOB4MR36DPJw8k+
# Q/x2SzDQREZRS6KMN6No3tDfVH6hLWH9X0mnj97LB0BSNNIJxS1KGAjwS5bu
# +38dfHEHXIGaCTRWv1iQee5GNgoQOGixMK5C4rq7aT1qAVfcFZfX6RtTq3Tv
# Ljmx2OF/XADK3CKpFozEhZeu/s/ew/Izi8PT80+4v0TNb0mn/9yrUPnHodZH
# spgtaICULRIqrGdOYLP4ej25Fdnm3yl9xpW/NJ/OmnQbF3sBSwyekoEzqw4B
# T10HmZNhwqUKvnrGFWN8WEufROJ3f742/YttYIxFV0l4ztbYZxM6qxGd72gu
# yV0NcpOQJkhGR4K5CpIQ6chjdcsIxWwvfAYcPHYQHVd2Kf8FrxSvqiEZGDET
# vsBch7QDokfpS73D7R/66wecbMCfzhMeywwrVa7rWAa0WKqNdyiyv3JhHR4X
# i5Nf07CgjMNOS3VMJ4SzcyuUFTT0FXjUSPmGR2YKu5TqTSXu6eo3WIp7SWAy
# Rbb1i6fvGPP50ZqfjpUwB42HzIMhPZGUf+QSnAzDZtRL5L+XodkneS1xdJGk
# 9mT8NWM4KWmrE1uHkRpn2Ol3L/3XTO8rxPCksVWd9uo7Fr1PU85NLbCTiK+E
# ZVmvoJKMo9EQc81cOOCpLgsI/EBi/hdt+NgCLnofXumGu0Ki96LTzNh554Dq
# JlkOxmZHo+suvxAlIuF+wno8wODGVOB+gURCgqn1By0f+SxsfFkYmjfh1VIs
# /e0D8X7Wi4A95WZyNQ2sJqZJu8DpUDC9sMmnyBPxNp+ieWPT3l5DJmXGFSpo
# CWlYo+YxdNJMFQ3ow5aNBPuVjtWQkAVjqssbx1smOhUohaQFIcB4TBNJZ4f6
# juFqjSm/lEpAwlgfYN3MmDcXEDu6qqmDNwNcRh8mB5ru9oXe6DVXZBbS32Gt
# iLeFhkpR1MzzkPg0+eB9el7gmlqDv/ev1IvQa29WfR1LD+ON7NT390eqnFpe
# /Gil62UIGxF3sjgk0wj3As/CzFpIhh/m35+xhBQDofNytxvUg5GjyLNIwfdu
# I0b86I47vKomFNnh3oiqo3rzn7MM03UU7Lxbpv9MN2cbVOGN7Wdg90jZZSB0
# Vh82s+X3kGbpBmBd3NPc1jFKlDEkolmap6q7DWVz4iPHq1IacifCiN/pTdzP
# X2j4BfMIg2jnOafvvp4/XS9INunVL9D+3iOdbR7+mF4A8lrxc4w43+94A87E
# vRjsobrK0HfclhvfKVakd4m60r6PXFz7fVy36Yh4skSmdDUNAuskCXIK+y8J
# W3yY3pZU/rkXBU22ilGltCEQkL02ZsHrTpuEBRNwMuw=')
# puts j