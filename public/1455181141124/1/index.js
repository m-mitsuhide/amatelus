jThree( function( j3 ) {

	$( "#loading" ).remove();

	j3.Orbit();


	function rotateEarth() {
		j3("#earth").animate({ rotateY: "+=3.14" }, 5000, rotateEarth);
	}
	rotateEarth();





},
function() {
	alert( "This browser does not support WebGL." );
} );
