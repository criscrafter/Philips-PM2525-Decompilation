// Post-analysis script: applies "label ADDR NAME" (CODE) and "slabel SPACE ADDR NAME" seeds.
// Done after auto-analysis so labels on jump-table targets do not get promoted to functions.
//@category PM2525
import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.*;
import ghidra.program.model.symbol.*;
import java.nio.file.*;
import java.util.*;

public class ApplyLabels extends GhidraScript {
    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        List<String> lines = Files.readAllLines(Paths.get(args[0]));
        SymbolTable st = currentProgram.getSymbolTable();
        AddressFactory af = currentProgram.getAddressFactory();
        int n = 0;
        for (String raw : lines) {
            String[] f = raw.trim().split("\s+");
            Address a = null; String name = null;
            if (f[0].equals("label") && f.length >= 3) {
                a = af.getDefaultAddressSpace().getAddress(Long.parseLong(f[1], 16)); name = f[2];
            } else if (f[0].equals("slabel") && f.length >= 4) {
                AddressSpace sp = af.getAddressSpace(f[1]);
                if (sp == null) { printerr("no space " + f[1]); continue; }
                a = sp.getAddress(Long.parseLong(f[2], 16)); name = f[3];
            } else continue;
            Symbol s = st.createLabel(a, name, SourceType.USER_DEFINED);
            s.setPrimary();
            n++;
        }
        println("Applied " + n + " labels");
    }
}
