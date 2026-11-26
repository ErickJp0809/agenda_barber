import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models.dart';
import 'store.dart';
import 'tema.dart';

/// Código de país que se antepone si el teléfono tiene 10 dígitos (52 = México).
const codigoPais = '52';

/// Abre WhatsApp con el recordatorio ya escrito.
/// Si no se puede abrir, copia el mensaje al portapapeles.
Future<void> enviarRecordatorio(Cita c, ScaffoldMessengerState messenger) async {
  final cli = store.cliente(c.clienteId);
  if (cli == null) return;
  final bar = store.barbero(c.barberoId);
  final conBarbero = bar == null ? '' : ' con ${bar.nombre}';
  final msg = 'Hola ${cli.nombre.split(' ').first}, te recordamos tu cita en '
      'JP Barber el ${fechaLarga(c.inicio)} a las ${horaTxt(c.inicio)} '
      '(${c.servicioNombre}$conBarbero). ¡Te esperamos!';

  var tel = cli.telefono.replaceAll(RegExp(r'\D'), '');
  if (tel.length == 10) tel = '$codigoPais$tel';
  final uri = Uri.parse('https://wa.me/$tel?text=${Uri.encodeComponent(msg)}');

  var ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok) {
    await Clipboard.setData(ClipboardData(text: msg));
    messenger.showSnackBar(const SnackBar(
      content: Text('No se pudo abrir WhatsApp. El mensaje quedó copiado.'),
    ));
  }
}
