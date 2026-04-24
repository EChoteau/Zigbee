import math

def generate_cordic_table(width, num_steps):
    # Scaling factor: PI maps to 2^(WIDTH-1)
    # This assumes a signed representation where 180 degrees is 0x8000...
    scale_factor = (2**(width - 1)) / math.pi
    
    print(f"// CORDIC Atan Table for WIDTH={width}, NUM_STEPS={num_steps}")
    print(f"localparam logic signed [{width}-1:0] ATAN_TABLE [0:{num_steps-1}] = '{{")
    
    for i in range(num_steps):
        # Calculate atan(1 / 2^i)
        angle_rad = math.atan(1.0 / (2**i))
        # Scale to fixed point integer
        scaled_angle = int(round(angle_rad * scale_factor))
        
        # Formatting for Verilog (hexadecimal)
        hex_val = format(scaled_angle & ((1 << width) - 1), f'0{width // 4}x')
        
        comma = "," if i < num_steps - 1 else ""
        print(f"    {width}'sh{hex_val}{comma} // step {i}: {math.degrees(angle_rad):.4f} deg")
        
    print("};")

if __name__ == "__main__":
    generate_cordic_table(width=8, num_steps=8)
