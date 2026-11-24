// Pre-analysis script: seeds code/functions/labels from a seeds file produced by make_seeds.py.
// Usage (headless): -preScript SeedFunctions.java <seeds.txt>
// Seeds format: "func ADDR NAME" | "code ADDR" | "label ADDR NAME" | "comment ADDR text"
//@category PM2525
import ghidra.app.script.GhidraScript;
import ghidra.app.cmd.disassemble.DisassembleCommand;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.symbol.*;
import java.io.*;
import java.nio.file.*;
import java.util.*;

public class SeedFunctions extends GhidraScript {
    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        if (args.length < 1) { printerr("need seeds file"); return; }
        List<String> lines = Files.readAllLines(Paths.get(args[0]));
        AddressSpace code = currentProgram.getAddressFactory().getDefaultAddressSpace();
        Listing listing = currentProgram.getListing();
        SymbolTable st = currentProgram.getSymbolTable();
        int nf = 0, nc = 0;
        List<String[]> funcs = new ArrayList<>();
        for (String raw : lines) {
            String l = raw.trim();
            if (l.isEmpty() || l.startsWith("#")) continue;
            String[] f = l.split("\\s+", 3);
            if (f[0].equals("jtab")) continue;   // handled after functions exist
            if (f[0].equals("label") || f[0].equals("slabel")) continue;   // applied post-analysis (ApplyLabels)
            Address a = f[0].equals("slabel") ? null : code.getAddress(Long.parseLong(f[1], 16));
            switch (f[0]) {
                case "code":
                case "func":
                    new DisassembleCommand(a, null, true).applyTo(currentProgram, monitor);
                    nc++;
                    if (f[0].equals("func")) funcs.add(f);
                    break;
                case "label":
                    st.createLabel(a, f[2], SourceType.USER_DEFINED);
                    break;
                case "slabel": {
                    // slabel SPACE HEXADDR NAME  (INTMEM / BITS / EXTMEM)
                    String[] g = l.split("\\s+");
                    AddressSpace sp = currentProgram.getAddressFactory().getAddressSpace(g[1]);
                    if (sp == null) { printerr("no space " + g[1]); break; }
                    Address da = sp.getAddress(Long.parseLong(g[2], 16));
                    Symbol sym = st.createLabel(da, g[3], SourceType.USER_DEFINED);
                    sym.setPrimary();
                    break;
                }
                case "comment":
                    listing.setComment(a, CommentType.PRE, f[2]);
                    break;
            }
        }
        for (String[] f : funcs) {
            Address a = code.getAddress(Long.parseLong(f[1], 16));
            Function fn = getFunctionAt(a);
            if (fn == null) fn = createFunction(a, f.length > 2 ? f[2] : null);
            else if (f.length > 2) fn.setName(f[2], SourceType.USER_DEFINED);
            if (fn != null) nf++;
        }
        // jump-table overrides: "jtab JMPADDR E1 E2 ..."
        int nj = 0;
        for (String raw : lines) {
            String l = raw.trim();
            if (!l.startsWith("jtab ")) continue;
            String[] f = l.split("\\s+");
            Address jmp = code.getAddress(Long.parseLong(f[1], 16));
            ArrayList<Address> dests = new ArrayList<>();
            for (int i = 2; i < f.length; i++) {
                Address d = code.getAddress(Long.parseLong(f[i], 16));
                dests.add(d);
                currentProgram.getReferenceManager().addMemoryReference(jmp, d, RefType.COMPUTED_JUMP,
                    SourceType.USER_DEFINED, 0);
            }
            Function fn = getFunctionContaining(jmp);
            if (fn == null) { printerr("jtab " + jmp + " not inside a function"); continue; }
            new ghidra.program.model.pcode.JumpTable(jmp, dests, true, 0).writeOverride(fn);
            nj++;
        }
        println("Seeded " + nc + " code starts, " + nf + " functions, " + nj + " jump tables");
    }
}
