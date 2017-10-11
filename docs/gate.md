# Type of gate
* Call gate
* Interrupt gate
* Trap gate

# Call gate
To use call gate in the code, we have several things need to do

* Because the target of call gate is a code segment. We need to setup the descriptor and the selector for target code first

* Setup the call gate descriptor

The descriptor structure looks like below

<table border="1px solid">
    <tr width="100%">
        <td>byte 7</td>
        <td>byte 6</td>
        <td>byte 5</td>
        <td>byte 4</td>
        <td>byte 3</td>
        <td>byte 2</td>
        <td>byte 1</td>
        <td>byte 0</td>
    </tr>
    <tr>
        <td style="text-align:center" colspan="2">31..16 offset</td>
        <td style="text-align:center" colspan="2">attributes</td>
        <td style="text-align:center" colspan="2">target selector</td>
        <td style="text-align:center" colspan="2">15..0 offset</td>
    </tr>
</table>

attribute is total 16 bits they are:

<table border="1px solid">
    <tr width="100%">
        <td>7</td>
        <td>6</td>
        <td>5</td>
        <td>4</td>
        <td>3</td>
        <td>2</td>
        <td>1</td>
        <td>0</td>
        <td>7</td>
        <td>6</td>
        <td>5</td>
        <td>4</td>
        <td>3</td>
        <td>2</td>
        <td>1</td>
        <td>0</td>
    </tr>
    <tr>
        <td>P</td>
        <td colspan="2">DPL</td>
        <td>S</td>
        <td style="text-align:center" colspan="4">Type</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td style="text-align:center" colspan="5">Param Count</td>
    </tr>
</table>

* Setup the call gate selector

* In code call ```asm call SelectorCallGate:0```

* When you call code B from code A through Gate G, following privilege checking will be applied, so the call gate will make it possible transmission from lower privilege to higher pribilege

<table>
    <tr>
        <td></td>
        <td>Call instruction</td>
        <td>Jmp instruction</td>        
    </tr>
    <tr>
        <td>B is synchronized code</td>
        <td colspan="2">CPL, RPL <= DPL_G and DPL_B <= CPL</td>
    </tr>
    <tr>
        <td>B is non-synchronized code</td>
        <td>CPL, RPL <= DPL_G and DPL_B <= CPL</td>
        <td>CPL, RPL <= DPL_G and DPL_B = CPL</td>
    </tr>
</table>

