import { cwd } from "process";
import { join } from "path";
import { writeFile } from "fs/promises";

import autoprefixer from "autoprefixer";
import cssnano from "cssnano";
import postcss from "postcss";
import nesting from "postcss-nesting";

const compiler = postcss([nesting, autoprefixer, cssnano]);

export const compile_css = async (css, name, next) => {
  const to = join(cwd(), `./priv/${name}.css`);
  const { css: out } = await compiler.process(css, { from: undefined, to });
  await writeFile(to, out, { encoding: "utf8" });

  next(out);
};
