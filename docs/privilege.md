# Privilege Type
* **CPL**
  The privilege of current running code. It is the bit 0 and bit 1 of cs and ss
* **DPL**
  The privilege defined in descriptor
* **RPL**
  The privilege defined in selector

# Privilege check
When code switchs to different privilege section, both **CPL** and **RPL** will both be checked against the target **DPL**. If both CPL and RPL check pass, then the call suss. Otherwise, the call fails

# Privilege check rule
* For DATA section, TSS section and CALL gate. Only CPL AND RPL <= DPL, call suss
* For synchronized code or non-synchronized code through call gate, CPL AND RPL >= DPL, call succ
* For non-synchronized code without CALL gate, CPL AND RPL == DPL


