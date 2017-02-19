//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

struct TGaussPoin
{
    float w;
    float x;
};

//------------------------------------------------------------------------------

struct TRay
{
    float3 Pos;
    float3 Vec;
};

inline TRay newTRay( const float3 Pos_, const float3 Vec_ )
{
    TRay Result;

    Result.Pos = Pos_;
    Result.Vec = Vec_;

    return Result;
}

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

const SamplerState _Sampler {};

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

static int3 _VoxelsN;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

inline int3 sign3( const float3 P_ )
{
    int3 Result;

    Result.x = sign( P_.x );
    Result.y = sign( P_.y );
    Result.z = sign( P_.z );

    return Result;
}

inline float3 abs3( const float3 P_ )
{
    float3 Result;

    Result.x = abs( P_.x );
    Result.y = abs( P_.y );
    Result.z = abs( P_.z );

    return Result;
}

inline int3 floor3( const float3 P_ )
{
    int3 Result;

    Result.x = floor( P_.x );
    Result.y = floor( P_.y );
    Result.z = floor( P_.z );

    return Result;
}

inline int MinI( const float A_, const float B_, const float C_ )
{
    if ( A_ <= B_ )
    {
        if ( A_ <= C_ ) return 0;
                   else return 2;
    }
    else
    {
        if ( B_ <= C_ ) return 1;
                   else return 2;
    }
}

inline int MinI( const float3 V_ )
{
    return MinI( V_.x, V_.y, V_.z );
}

////////////////////////////////////////////////////////////////////////////////

inline float4 GetVolume( const float3 G_ )
{
    return _Texture3D.Sample( _Sampler, ( G_ + 0.5 ) / _VoxelsN );
}

inline float4 GetVolume( const float X_, const float Y_, const float Z_ )
{
    return GetVolume( float3( X_, Y_, Z_ ) );
}

////////////////////////////////////////////////////////////////////////////////

inline float BSplin4( const float X_ )
{
    float X = abs( X_ );

    if ( X < 1 ) return ( 0.5 * X - 1 ) * X * X + 2.0/3.0;
            else
    if ( X < 2 ) return ( ( 1.0 - 1.0/6.0 * X ) * X - 2.0 ) * X + 4.0/3.0;
            else return 0;
}

inline float4 BSpline4( const float4 C0_,
                        const float4 C1_,
                        const float4 C2_,
                        const float4 C3_,
                        const float  Td_ )
{
    return C0_ * BSplin4( Td_ + 1 )
         + C1_ * BSplin4( Td_     )
         + C2_ * BSplin4( Td_ - 1 )
         + C3_ * BSplin4( Td_ - 2 );
}

inline float4 GetVolumeBS4( const float3 G_ )
{
    int3   Gi = floor3( G_ );
    float3 Gd = G_ - Gi;

    float4 C000 = GetVolume( Gi.x-1, Gi.y-1, Gi.z-1 );
    float4 C001 = GetVolume( Gi.x  , Gi.y-1, Gi.z-1 );
    float4 C002 = GetVolume( Gi.x+1, Gi.y-1, Gi.z-1 );
    float4 C003 = GetVolume( Gi.x+2, Gi.y-1, Gi.z-1 );
    float4 C010 = GetVolume( Gi.x-1, Gi.y  , Gi.z-1 );
    float4 C011 = GetVolume( Gi.x  , Gi.y  , Gi.z-1 );
    float4 C012 = GetVolume( Gi.x+1, Gi.y  , Gi.z-1 );
    float4 C013 = GetVolume( Gi.x+2, Gi.y  , Gi.z-1 );
    float4 C020 = GetVolume( Gi.x-1, Gi.y+1, Gi.z-1 );
    float4 C021 = GetVolume( Gi.x  , Gi.y+1, Gi.z-1 );
    float4 C022 = GetVolume( Gi.x+1, Gi.y+1, Gi.z-1 );
    float4 C023 = GetVolume( Gi.x+2, Gi.y+1, Gi.z-1 );
    float4 C030 = GetVolume( Gi.x-1, Gi.y+2, Gi.z-1 );
    float4 C031 = GetVolume( Gi.x  , Gi.y+2, Gi.z-1 );
    float4 C032 = GetVolume( Gi.x+1, Gi.y+2, Gi.z-1 );
    float4 C033 = GetVolume( Gi.x+2, Gi.y+2, Gi.z-1 );

    float4 C100 = GetVolume( Gi.x-1, Gi.y-1, Gi.z   );
    float4 C101 = GetVolume( Gi.x  , Gi.y-1, Gi.z   );
    float4 C102 = GetVolume( Gi.x+1, Gi.y-1, Gi.z   );
    float4 C103 = GetVolume( Gi.x+2, Gi.y-1, Gi.z   );
    float4 C110 = GetVolume( Gi.x-1, Gi.y  , Gi.z   );
    float4 C111 = GetVolume( Gi.x  , Gi.y  , Gi.z   );
    float4 C112 = GetVolume( Gi.x+1, Gi.y  , Gi.z   );
    float4 C113 = GetVolume( Gi.x+2, Gi.y  , Gi.z   );
    float4 C120 = GetVolume( Gi.x-1, Gi.y+1, Gi.z   );
    float4 C121 = GetVolume( Gi.x  , Gi.y+1, Gi.z   );
    float4 C122 = GetVolume( Gi.x+1, Gi.y+1, Gi.z   );
    float4 C123 = GetVolume( Gi.x+2, Gi.y+1, Gi.z   );
    float4 C130 = GetVolume( Gi.x-1, Gi.y+2, Gi.z   );
    float4 C131 = GetVolume( Gi.x  , Gi.y+2, Gi.z   );
    float4 C132 = GetVolume( Gi.x+1, Gi.y+2, Gi.z   );
    float4 C133 = GetVolume( Gi.x+2, Gi.y+2, Gi.z   );

    float4 C200 = GetVolume( Gi.x-1, Gi.y-1, Gi.z+1 );
    float4 C201 = GetVolume( Gi.x  , Gi.y-1, Gi.z+1 );
    float4 C202 = GetVolume( Gi.x+1, Gi.y-1, Gi.z+1 );
    float4 C203 = GetVolume( Gi.x+2, Gi.y-1, Gi.z+1 );
    float4 C210 = GetVolume( Gi.x-1, Gi.y  , Gi.z+1 );
    float4 C211 = GetVolume( Gi.x  , Gi.y  , Gi.z+1 );
    float4 C212 = GetVolume( Gi.x+1, Gi.y  , Gi.z+1 );
    float4 C213 = GetVolume( Gi.x+2, Gi.y  , Gi.z+1 );
    float4 C220 = GetVolume( Gi.x-1, Gi.y+1, Gi.z+1 );
    float4 C221 = GetVolume( Gi.x  , Gi.y+1, Gi.z+1 );
    float4 C222 = GetVolume( Gi.x+1, Gi.y+1, Gi.z+1 );
    float4 C223 = GetVolume( Gi.x+2, Gi.y+1, Gi.z+1 );
    float4 C230 = GetVolume( Gi.x-1, Gi.y+2, Gi.z+1 );
    float4 C231 = GetVolume( Gi.x  , Gi.y+2, Gi.z+1 );
    float4 C232 = GetVolume( Gi.x+1, Gi.y+2, Gi.z+1 );
    float4 C233 = GetVolume( Gi.x+2, Gi.y+2, Gi.z+1 );

    float4 C300 = GetVolume( Gi.x-1, Gi.y-1, Gi.z+2 );
    float4 C301 = GetVolume( Gi.x  , Gi.y-1, Gi.z+2 );
    float4 C302 = GetVolume( Gi.x+1, Gi.y-1, Gi.z+2 );
    float4 C303 = GetVolume( Gi.x+2, Gi.y-1, Gi.z+2 );
    float4 C310 = GetVolume( Gi.x-1, Gi.y  , Gi.z+2 );
    float4 C311 = GetVolume( Gi.x  , Gi.y  , Gi.z+2 );
    float4 C312 = GetVolume( Gi.x+1, Gi.y  , Gi.z+2 );
    float4 C313 = GetVolume( Gi.x+2, Gi.y  , Gi.z+2 );
    float4 C320 = GetVolume( Gi.x-1, Gi.y+1, Gi.z+2 );
    float4 C321 = GetVolume( Gi.x  , Gi.y+1, Gi.z+2 );
    float4 C322 = GetVolume( Gi.x+1, Gi.y+1, Gi.z+2 );
    float4 C323 = GetVolume( Gi.x+2, Gi.y+1, Gi.z+2 );
    float4 C330 = GetVolume( Gi.x-1, Gi.y+2, Gi.z+2 );
    float4 C331 = GetVolume( Gi.x  , Gi.y+2, Gi.z+2 );
    float4 C332 = GetVolume( Gi.x+1, Gi.y+2, Gi.z+2 );
    float4 C333 = GetVolume( Gi.x+2, Gi.y+2, Gi.z+2 );

    float4 C00 = BSpline4( C000, C001, C002, C003, Gd.x );
    float4 C01 = BSpline4( C010, C011, C012, C013, Gd.x );
    float4 C02 = BSpline4( C020, C021, C022, C023, Gd.x );
    float4 C03 = BSpline4( C030, C031, C032, C033, Gd.x );

    float4 C10 = BSpline4( C100, C101, C102, C103, Gd.x );
    float4 C11 = BSpline4( C110, C111, C112, C113, Gd.x );
    float4 C12 = BSpline4( C120, C121, C122, C123, Gd.x );
    float4 C13 = BSpline4( C130, C131, C132, C133, Gd.x );

    float4 C20 = BSpline4( C200, C201, C202, C203, Gd.x );
    float4 C21 = BSpline4( C210, C211, C212, C213, Gd.x );
    float4 C22 = BSpline4( C220, C221, C222, C223, Gd.x );
    float4 C23 = BSpline4( C230, C231, C232, C233, Gd.x );

    float4 C30 = BSpline4( C300, C301, C302, C303, Gd.x );
    float4 C31 = BSpline4( C310, C311, C312, C313, Gd.x );
    float4 C32 = BSpline4( C320, C321, C322, C323, Gd.x );
    float4 C33 = BSpline4( C330, C331, C332, C333, Gd.x );

    float4 C0 = BSpline4( C00, C01, C02, C03, Gd.y );
    float4 C1 = BSpline4( C10, C11, C12, C13, Gd.y );
    float4 C2 = BSpline4( C20, C21, C22, C23, Gd.y );
    float4 C3 = BSpline4( C30, C31, C32, C33, Gd.y );

    return BSpline4( C0, C1, C2, C3, Gd.z );
}

////////////////////////////////////////////////////////////////////////////////

inline float4 GetField( const float3 P_ )
{
    float3 G = P_ / _Size * _VoxelsN - 0.5;

    return GetVolume   ( G );  // Linear    Interpolation
  //return GetVolumeBS4( G );  // B-Spline4 Interpolation
}

////////////////////////////////////////////////////////////////////////////////

inline float4 GetAccum1( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin Gs[ 1 ] = { { 2, 0 } };

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    float A = Gs[ 0 ].w * GetField( R_.Vec * ( R * Gs[ 0 ].x + C ) + R_.Pos );

    return R * A;
}

inline float4 GetAccum2( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin G[ 1 ] = { { 1.0, sqrt( 1.0 / 3.0 ) } };

    const TGaussPoin Gs[ 2 ] = { { G[ 0 ].w, -G[ 0 ].x },
                                 { G[ 0 ].w, +G[ 0 ].x } };

    float4 Result = 0;

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    [unroll]
    for ( uint I = 0; I < 2; I++ )
    {
        Result += Gs[ I ].w * GetField( R_.Vec * ( R * Gs[ I ].x + C ) + R_.Pos );
    }

    return R * Result;
}

inline float4 GetAccum3( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin G[ 2 ] = { { 8.0 / 9.0, 0.0               },
                                { 5.0 / 9.0, sqrt( 3.0 / 5.0 ) } };

    const TGaussPoin Gs[ 3 ] = { { G[ 1 ].w, -G[ 1 ].x },
                                 { G[ 0 ].w,  G[ 0 ].x },
                                 { G[ 1 ].w, +G[ 1 ].x } };

    float4 Result = 0;

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    [unroll]
    for ( uint I = 0; I < 3; I++ )
    {
        Result += Gs[ I ].w * GetField( R_.Vec * ( R * Gs[ I ].x + C ) + R_.Pos );
    }

    return R * Result;
}

inline float4 GetAccum4( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin G[ 2 ] = { { ( 18.0 + sqrt( 30.0 ) ) / 36.0, sqrt( ( 3.0 - 2.0 * sqrt( 6.0 / 5.0 ) ) / 7.0 ) },
                                { ( 18.0 - sqrt( 30.0 ) ) / 36.0, sqrt( ( 3.0 + 2.0 * sqrt( 6.0 / 5.0 ) ) / 7.0 ) } };

    const TGaussPoin Gs[ 4 ] = { { G[ 1 ].w, -G[ 1 ].x },
                                 { G[ 0 ].w, -G[ 0 ].x },
                                 { G[ 0 ].w, +G[ 0 ].x },
                                 { G[ 1 ].w, +G[ 1 ].x } };

    float4 Result = 0;

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    [unroll]
    for ( uint I = 0; I < 4; I++ )
    {
        Result += Gs[ I ].w * GetField( R_.Vec * ( R * Gs[ I ].x + C ) + R_.Pos );
    }

    return R * Result;
}

inline float4 GetAccum5( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin G[ 3 ] = { {   128.0                         / 225.0, 0.0                                          },
                                { ( 322.0 + 13.0 * sqrt( 70.0 ) ) / 900.0, sqrt( 5.0 - 2.0 * sqrt( 10.0 / 7.0 ) ) / 3.0 },
                                { ( 322.0 - 13.0 * sqrt( 70.0 ) ) / 900.0, sqrt( 5.0 + 2.0 * sqrt( 10.0 / 7.0 ) ) / 3.0 } };

    const TGaussPoin Gs[ 5 ] = { { G[ 2 ].w, -G[ 2 ].x },
                                 { G[ 1 ].w, -G[ 1 ].x },
                                 { G[ 0 ].w,  G[ 0 ].x },
                                 { G[ 1 ].w, +G[ 1 ].x },
                                 { G[ 2 ].w, +G[ 2 ].x } };

    float4 Result = 0;

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    [unroll]
    for ( uint I = 0; I < 5; I++ )
    {
        Result += Gs[ I ].w * GetField( R_.Vec * ( R * Gs[ I ].x + C ) + R_.Pos );
    }

    return R * Result;
}

//##############################################################################

struct TSenderP
{
    float4 Scr :SV_Position;
    float4 Pos :TEXCOORD0  ;
};

struct TResultP
{
    float4 Col :SV_Target;
};

////////////////////////////////////////////////////////////////////////////////

TResultP MainP( const TSenderP _Sender )
{
    _Texture3D.GetDimensions( _VoxelsN.x, _VoxelsN.y, _VoxelsN.z );

    TResultP Result;

    float3 E = mul( _EyePos, _MatrixGL ).xyz;

    TRay R = newTRay( _Sender.Pos.xyz, normalize( _Sender.Pos.xyz - E ) );

    int3 Gv = sign3( R.Vec );

    int3 Gvs[ 3 ] = { { Gv.x,    0,    0 },
                      {    0, Gv.y,    0 },
                      {    0,    0, Gv.z } };

    float3 Sd = _Size / _VoxelsN;

    float3 Tv = Sd / abs3( R.Vec );

    float3 Tvs[ 3 ] = { { Tv.x,    0,    0 },
                        {    0, Tv.y,    0 },
                        {    0,    0, Tv.z } };

    float3 G = R.Pos / Sd - 0.5;

    int3 Gi = floor3( G );

    float3 Gd = G - Gi;

    float3 Ts;
    if ( R.Vec.x > 0 ) Ts.x = Tv.x * ( 1 - Gd.x ); else Ts.x = Tv.x * Gd.x;
    if ( R.Vec.y > 0 ) Ts.y = Tv.y * ( 1 - Gd.y ); else Ts.y = Tv.y * Gd.y;
    if ( R.Vec.z > 0 ) Ts.z = Tv.z * ( 1 - Gd.z ); else Ts.z = Tv.z * Gd.z;

    Result.Col = 0;

    float T0 = 0;

    [loop]
    while ( ( -1 <= Gi.x ) && ( Gi.x <= _VoxelsN.x )
         && ( -1 <= Gi.y ) && ( Gi.y <= _VoxelsN.y )
         && ( -1 <= Gi.z ) && ( Gi.z <= _VoxelsN.z ) )
    {
        int K = MinI( Ts );

        float T1 = Ts[ K ];

        Result.Col += GetAccum2( R, T0, T1 );

        T0 = T1;

        Gi += Gvs[ K ];
        Ts += Tvs[ K ];
    }

    Result.Col /= 6;

    //--------------------------------------------------------------------------

    Result.Col.a = 0;

    Result.Col = _Opacity * Result.Col;

    return Result;
}

//##############################################################################
