3򤰗�3鄹J�" QSP� 笌描X[YPSQRV桉 ^ZY[X惛 L�!悑�3谰� �<-u�|hu�	篧�!惛 L�!愯g P鑓 3蹔�3繶婙3繱3坭R P鐽 3蓨�3繶娙3繯3设= �3繡�5 �3繡婣䥺鄩A䞍�r鉝3�� 3�3垃� < u3垃怊冾嬛XY[�3垃< u3垃膑冾3拉喣<as	<As,0��,a
��,A
�黙s�麬s��0�悁靉��
�悁霢��
P2篮 麾Z娐�2涿孃SP3缞镁� 麈嬝3�3鯴嬻[2蹔�2��3鯯Q2蓨�2韹饗D&�兠�栝 婦&�Y[S伱� PQ3栏� 2眵釈�3��3蒠XQ2蓨�2韹D&�兠�璨 婦
&�Y[SQ2韥脿 婦瑗 3�3踄[SQ2蓨�2韥芒 �資Q2韹D鑵 Y[伱� SQ嬿3見6V�<$tR�<\u%�|nu兤XP娔*艎�2濑蓙脿 +�+貈� w噪)悐&�兠F���� w繶婌P伱� 娔2�+�+貈� w℡Y冒󷤡酃0&�兠怿�&�兠怿�&�伱� 怊猛	�	�	�	�	�		usage: (length of name represents required amount of digits, except for the text. All numbers are hex.)
frame.com X0 Y0 LX LY FRXL FRYL FLTC FRTC FLBC FRBC TS TEXT_TO_BE_DISPLAYED
Where  : 
X0 - left top X coord in range [00h, 50h]
Y0 - left top Y coord in range [00h, 1Eh]
LX - X length of working zone
LY - Y length of working zone
FRXL, FRYL - hex codes of horizontal and vertical line symbols
FLTC, FRTC, FLBC, FRBC - left top, right top, left bottom and right bottom angles' codes
TS - text style, a 2 digit hex
TEXT_TO_BE_DISPLAYED - the text, ending in dollar sign$