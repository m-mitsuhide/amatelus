jThree( function( j3 ) {

	$( "#loading" ).remove();

	j3.Orbit();


	function rotateEarth() {
		j3("#earth").animate({ rotateY: "+=3.14" }, 50000, rotateEarth);
	}
	rotateEarth();

    $( "#room" ).click( function() {
        $( this ).hide();
    });



},
function() {
	alert( "This browser does not support WebGL." );
} );
