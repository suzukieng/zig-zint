const std = @import("std");

// import the Zint C library
const zint = @cImport({
    @cInclude("zint.h");
});


/// expose symbologies, and use Zint's underlying integer representation for itss value.
pub const Symbology = enum(c_int) {
    qr = zint.BARCODE_QRCODE,
    dm = zint.BARCODE_DATAMATRIX,
    aztec = zint.BARCODE_AZTEC,
    ultracode = zint.BARCODE_ULTRA
    // add more as needed...
};

pub fn generateSVG(allocator: std.mem.Allocator, symbology: Symbology, text: []const u8) ![]const u8 {
    if (zint.ZBarcode_ValidID(@intFromEnum(symbology)) == 0) {
        return error.invalidSymbology;
    }
    const zSym = zint.ZBarcode_Create();
    defer zint.ZBarcode_Delete(zSym);
    const text_len: c_int = @intCast(text.len);
    const out_filename = "out.svg";
    @memcpy(zSym.*.outfile[0..out_filename.len], out_filename);
    zSym.*.symbology = @intFromEnum(symbology);
    zSym.*.output_options = zint.BARCODE_MEMORY_FILE;
    _ = zint.ZBarcode_Encode_and_Print(zSym, text.ptr, text_len, 0);

    // copy SVG output into allocator-owned memory, Zint memfile be released by ZBarcode_Delete
    const svg_len: u32 = @intCast(zSym.*.memfile_size);
    const svg_output = try allocator.alloc(u8, svg_len);
    @memcpy(svg_output, zSym.*.memfile);
    return svg_output;
}