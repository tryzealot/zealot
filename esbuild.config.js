const watch = process.argv.includes("--watch") && {
  onRebuild(error) {
    if (error) console.error("[watch] build failed", error)
    else console.log("[watch] build finished")
  }
}

require('esbuild').build({
  entryPoints: ['app/javascript/*.*'],
  bundle: true,
  sourcemap: true,
  watch: watch,
  outdir: 'app/assets/builds'
}).catch(() => process.exit(1))