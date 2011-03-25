dt = new Date();
y = dt.getYear() + 1900;
m = dt.getMonth() + 1;

document.write("<table>");
document.write("<tr><td align=center colspan=7>");
document.write(y + "/");
if (m < 10) { document.write("&nbsp;"); }
document.write(m);
document.write("</td></tr>");
document.write("<tr>");
document.write("<td>日</td><td>月</td><td>火</td><td>水</td><td>木</td><td>金</td><td>土</td>");
document.write("</tr>");

sdy = 1;
edy = new Date(y, m, 0).getDate();

document.write("<tr>");
for (i = sdy; i < edy + 1; i++) {
    k = new Date(y, m - 1, i);
    if (i == sdy) {
       for (j = 0; j < k.getDay(); j++) {
           document.write("<td>&nbsp;</td>");
       }
    } else if (k.getDay() == 0) {
       document.write("</tr>");
    }
    document.write("<td align='right'>");
    document.write(i);
    document.write("</td>");
}
document.write("</tr></table>");
