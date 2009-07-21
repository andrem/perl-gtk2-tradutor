#!/usr/bin/perl -w
#
# Tradutor is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
#  PerlPanel is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with PerlPanel; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#  Copyright: (C) 2006 Andre Osti de Moura <andreoandre [at] gmail [dot] com>
#
#  $Id: tradutor.pl,v 1.0 2006/01/07 20:03:57 Andre Osti de Moura $
#
use strict;
use Gtk2 -init;
use Gtk2::GladeXML;
use IO::Socket::INET;

my ( $tradutor, $window, $texto, $resp, $traduzir );

#
# Chama o arquivo XML feito no Glade
$tradutor = Gtk2::GladeXML->new('tradutor.glade');
$window   = $tradutor->get_widget('tradutor');

#
# Para finalizar a janela
$window->signal_connect( delete_event => sub { Gtk2->main_quit; 1 } );

#
# Armazena o texto digitado para a busca
$texto = $tradutor->get_widget('texto');

$tradutor->signal_autoconnect_from_package('main');
Gtk2->main;

#
# Funcao que realiza a busca
#
sub on_traduzir_clicked {
    my ($texto_entrada);
    $texto_entrada = $texto->get_text();

    my $sock
        = IO::Socket::INET->new( PeerAddr => 'translate.google.com:tcp(80)' )
        or die "Erro ao Conectar $! \n";

    #
    # Envia a Busca ao site do google, se desejar mudar o tipo de busca,basta
    # altera a variavel en|pt para a lingua que deseja
    #

    $sock->send(
        "GET /translate_t?hl=pt-BR&ie=UTF8&langpair=en|pt&text=$texto_entrada HTTP/1.0\r\nHost: translate.google.com\r\n\r\n"
    );
    my $d;
    while (<$sock>) { $d .= $_; }
    $d =~ /ltr[^ltr]*<\/div>/;
    $d = $&;
    $d =~ s/<\/div>//;
    $d =~ s/ltr>//;
    $resp = $tradutor->get_widget('resposta')->get_buffer->set_text($d);
    close($sock);
}

