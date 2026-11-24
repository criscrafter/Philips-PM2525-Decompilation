// Post-analysis script: decompiles every function into one C file (and an index CSV).
// Usage (headless): -postScript DecompileAll.java <out.c>
//@category PM2525
import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.listing.*;
import java.io.*;

public class DecompileAll extends GhidraScript {
    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        String out = args.length > 0 ? args[0] : "decompiled.c";
        DecompInterface di = new DecompInterface();
        DecompileOptions opts = new DecompileOptions();
        opts.setMaxInstructions(200000);
        opts.setMaxPayloadMBytes(200);
        di.setOptions(opts);
        di.toggleCCode(true);
        di.toggleSyntaxTree(false);
        di.openProgram(currentProgram);
        int ok = 0, bad = 0;
        try (PrintWriter w = new PrintWriter(new FileWriter(out));
             PrintWriter idx = new PrintWriter(new FileWriter(out + ".index.csv"))) {
            w.println("// Ghidra " + getGhidraVersion() + " decompilation of " + currentProgram.getName());
            w.println("// Auto-generated. Names come from tools/s25.sym where known.\n");
            idx.println("entry,name,body_bytes,status");
            FunctionIterator it = currentProgram.getFunctionManager().getFunctions(true);
            while (it.hasNext() && !monitor.isCancelled()) {
                Function f = it.next();
                DecompileResults r = di.decompileFunction(f, 120, monitor);
                String status;
                w.println("// ======================================================================");
                w.println("// " + f.getName() + " @ " + f.getEntryPoint() + "  (" + f.getBody().getNumAddresses() + " bytes)");
                if (r != null && r.decompileCompleted() && r.getDecompiledFunction() != null) {
                    w.println(r.getDecompiledFunction().getC());
                    ok++; status = "ok";
                } else {
                    w.println("// DECOMPILATION FAILED: " + (r == null ? "null" : r.getErrorMessage()));
                    bad++; status = "failed";
                }
                idx.println(f.getEntryPoint() + "," + f.getName() + "," + f.getBody().getNumAddresses() + "," + status);
            }
        }
        di.dispose();
        println("Decompiled " + ok + " functions, " + bad + " failed -> " + out);
    }
}
